require 'java'
require 'benchmark'
require 'fileutils'

def server_dir
  ENV['BI_SERVER'] || '/usr/local/pentaho/server'
end

Dir.glob(File.join(server_dir, 'metadata-editor', 'libext', '**', '*.jar')) do |f|
  require f
end


CWM = Java::OrgPentahoPmsCore::CWM
CwmSchemaFactory = Java::OrgPentahoPmsFactory::CwmSchemaFactory
Relationship = Java::OrgPentahoPmsSchema::RelationshipMeta
BusinessModel = Java::OrgPentahoPmsSchema::BusinessModel
BusinessTable = Java::OrgPentahoPmsSchema::BusinessTable
BusinessCategory = Java::OrgPentahoPmsSchema::BusinessCategory
PhysicalColumn = Java::OrgPentahoPmsSchema::PhysicalColumn
PhysicalTable = Java::OrgPentahoPmsSchema::PhysicalTable
PublisherUtil = Java::OrgPentahoPlatformUtilClient::PublisherUtil

def load_metadata_xmi(file_path)
  Metadata.new(file_path)
end

class Metadata
  def initialize(file_path)
    FileUtils.rm Dir.glob('mdr.*')
    @schema_factory = CwmSchemaFactory.new
    @cwm = CWM.get_instance('TriSano')
    @cwm.importFromXMI File.join(server_dir, 'biserver-ee/pentaho-solutions/TriSano/metadata.xmi')
    @meta = @schema_factory.getSchemaMeta(@cwm)
  end

  def writable_database
    @meta.databases.each {|db| return Database.new(db) if db.name =~ /Update Script Connection/}
  end

  def ro_database
    @meta.databases.each {|db| return Database.new(db) unless db.name =~ /Update Script Connection/}
  end

  def update_from_database
    writable_database.modified_tables.each do |short_name, table_name|
      update_physical_table table_name
      update_business_table table_name do |table|
        secure_table(table)
        event_table = table_name =~ /contact/ ? contact_events_table : morbidity_events_table
        create_relationship({ 
          :from => table, 
          :to   => event_table,
          :type => "N:1"})
        update_category category_name(short_name), table, event_table
      end
    end    
    @schema_factory.store_schema_meta(@cwm, @meta, nil)
    publish({ :success => lambda{ puts "Sucess!" },
              :failures => lambda{ |result| "Failed because #{result}" }})
  end

  def category_name(name)
    name.split('_').collect{|word| word.capitalize}.join(' ')
  end

  def find_physical_table(table_name)
    @meta.find_physical_table(table_name)
  end

  def find_business_table(table_name)
    trisano_business_model.find_business_table(table_name)
  end

  def find_business_category(category_name)
    trisano_business_model.root_category.business_categories.each do |bc|
      return bc if bc.get_id == category_name
    end
  end

  def trisano_business_model
    @trisano_business_model ||= @meta.find_model('TriSano')
  end

  def view_for(table_name)
    "#{table_name}_view"
  end

  def create_relationship(options)
    relationship = Relationship.new
    relationship.table_from = options[:from]
    relationship.field_from = options[:from].find_business_column('event_id')
    relationship.table_to   = options[:to]
    relationship.field_to   = options[:to].id_column
    relationship.type       = options[:type]
    trisano_business_model.add_relationship relationship
  end

  def update_physical_table(table_name)
    pt = find_physical_table view_for(table_name)
    if pt.nil?
      pt = PhysicalTable.new view_for(table_name)
      pt.set_database_meta(ro_database.meta)
      pt.set_target_schema('trisano')
      pt.set_target_table view_for(table_name)
      @meta.add_table(pt)
    end
    writable_database.column_names_for(table_name).each do |column_name|
      unless pt.find_physical_column(column_name)
        pt.add_physical_column PhysicalColumn.new(column_name) unless pt.has_column?(column_name)
      end
    end
  end

  def update_business_table(table_name)
    pt = find_physical_table view_for(table_name)
    unless pt.nil?
      table = find_business_table view_for(table_name)
      if table.nil?
        table = Java::OrgPentahoPmsSchema::BusinessTable.new view_for(table_name), pt
        trisano_business_model.add_business_table table
      end
      pt.physical_columns.each do |pc|        
        bc = Java::OrgPentahoPmsSchema::BusinessColumn.new
        bc.set_id pc.get_id
        bc.physical_column = pc
        bc.business_table = table
        table.add_business_column bc unless table.has_column?(pc)
      end
      yield table
    end
  end

  def update_category(category_name, *tables)
    category = find_business_category(category_name)
    if category.nil?
      category = BusinessCategory.new(category_name)
      trisano_business_model.add_category(category)
    end
    tables.each do |table|
      table.business_columns.each do |column|
        category.add_business_column(column) unless category.has_column?(column.get_id)
      end
    end
  end

  def publish(result_hooks={})
    File.open('metadata.xmi', 'w') do |io|
      io << @cwm.getXMI
    end
    files = [Java::JavaIo::File.new('metadata.xmi')].to_java(Java::JavaIo::File)
    result = Java::OrgPentahoPlatformUtilClient::PublisherUtil.publish(server_url, 'TriSano', files, publisher_password, fs_user, fs_user_password, true)
    puts "Hows come my hooks aren't getting called?: #{result}"
    result_hooks[:success].call(result) if result_hooks[:success] && result == Java::OrgPentahoPlatformUtilClient::PublisherUtil::FILE_ADD_SUCCESSFUL
    result_hooks[:failure].call(result) if result_hooks[:failure] && result != Java::OrgPentahoPlatformUtilClient::PublisherUtil::FILE_ADD_SUCCESSFUL
  end

  def morbidity_events_table
    find_business_table 'MorbidityEvents'
  end

  def contact_events_table
    find_business_table 'ContactEvents'
  end

  def secure_table(table)
    table.concept.add_property security_property
  end

  def rights_mask
    @rights_mask ||= @meta.get_security_reference.find_acl("All").mask
  end

  def security
    owner = Java::OrgPentahoPmsSchemaSecurity::SecurityOwner.new role_type, "Authenticated"
    security = Java::OrgPentahoPmsSchemaSecurity::Security.new
    security.putOwnerRights owner, rights_mask
    security
  end

  def security_property
    Java::OrgPentahoPmsSchemaConceptTypesSecurity::ConceptPropertySecurity.new('security', security)
  end

  def role_type
    Java::OrgPentahoPmsSchemaSecurity::SecurityOwner::OWNER_TYPE_ROLE
  end

  def server_url    
    ENV['BI_SERVER_URL'] || 'http://localhost:8080/pentaho/RepositoryFilePublisher'
  end

  def publisher_password
    ENV['PUBLISHER_PASSWORD'] || 'password'
  end

  def fs_user
    ENV['FS_USER'] || 'joe'
  end

  def fs_user_password
    ENV['FS_USER_PASSWORD'] || 'password'
  end

  class Database
    def initialize(database_info)
      @database_info = database_info
    end

    def meta
      @database_info
    end

    def execute(sql)
      connection do |conn|
        conn.prepare_call(sql).execute_update
      end
    end

    def query(sql)
      connection do |conn|
        conn.prepare_call(sql).execute_query
      end      
    end

    def connection
      props = Java::JavaUtil::Properties.new
      props.setProperty "user", @database_info.username
      props.setProperty "password", @database_info.password
      begin
        conn = create.connect @database_info.getURL, props
        yield conn
      ensure
        conn.close if conn
      end
    end

    def create
      eval("#{@database_info.driver_class}").new
    end

    def modified_tables
      rs = query("SELECT short_name, table_name FROM trisano.formbuilder_tables WHERE modified=true;")
      results = []
      while rs.next        
        results << [rs.getString(1), rs.getString(2)]
      end
      results
    end

    def column_names_for(table_name)
      rs = query("SELECT column_name FROM trisano.formbuilder_columns WHERE formbuilder_table_name='#{table_name}'")
      results = []
      while rs.next
        results << rs.getString(1)
      end      
      results.empty? ? results : %w(event_id type) + results
    end
  end
end

BusinessModel.class_eval do  
  def find_relationships_from(table)    
    relationships.select {|r| r.table_from.get_id == table.get_id}
  end

  def add_category(category)
    root_category.add_business_category(category)
  end
end

BusinessTable.class_eval do
  def id_column
    @id_column ||= business_columns.each { |c| return c if c.get_id =~ /VIEW_ID$/ }
  end
  
  def has_column?(physical_column)
    !find_business_column(physical_column.get_id).nil?
  end
end

BusinessCategory.class_eval do
  def has_column?(column_name)
    !find_business_column(column_name).nil?
  end
end

PhysicalTable.class_eval do
  def has_column?(column_name)
    !find_physical_column(column_name).nil?
  end
end
