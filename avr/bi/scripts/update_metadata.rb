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

def load_metadata_xmi(file_path)
  Metadata.new(file_path)
end

class Metadata
  def initialize(file_path)
    FileUtils.rm Dir.glob('mdr.*')
    schema_factory = CwmSchemaFactory.new
    cwm = CWM.get_instance('TriSano')
    cwm.importFromXMI File.join(server_dir, 'biserver-ee/pentaho-solutions/TriSano/metadata.xmi')
    @meta = schema_factory.getSchemaMeta(cwm)
  end

  def writable_database
    @meta.databases.each {|db| return Database.new(db) if db.name =~ /Update Script Connection/}
  end

  def ro_database
    @meta.databases.each {|db| return Database.new(db) unless db.name =~ /Update Script Connection/}
  end

  def update_from_database
    writable_database.modified_tables.each do |table_name|
      update_physical_table table_name
      update_business_table table_name do |table|
        secure_table(table)
        create_relationship({ 
          :from => table, 
          :to   => (table_name =~ /contact/ ? contact_events_table : morbidity_events_table),
          :type => "N:1"})
      end
    end
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
      pt = Java::OrgPentahoPmsSchema::PhysicalTable.new view_for(table_name)
      pt.set_database_meta(ro_database.meta)
      pt.set_target_schema('trisano')
      pt.set_target_table view_for(table_name)
      @meta.add_table(pt)
    end
    writable_database.column_names_for(table_name).each do |column_name|
      unless pt.find_physical_column(column_name)
        pt.add_physical_column Java::OrgPentahoPmsSchema::PhysicalColumn.new(column_name)
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
        table.add_business_column bc
      end
      yield table
    end
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
      rs = query("SELECT table_name FROM trisano.formbuilder_tables WHERE modified=true;")
      results = []
      while rs.next
        results << rs.getString(1)
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
end

BusinessTable.class_eval do
  def id_column
    @id_column ||= business_columns.each { |c| return c if c.get_id =~ /VIEW_ID$/ }
  end
end
