# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

# XXX Make sure we can set security, etc. even if no tables are modified

require 'java'
require 'benchmark'
require 'fileutils'

def server_dir
  ENV['BI_SERVER_PATH'] || '/usr/local/pentaho/server/biserver-ce'
end

def require_jars(jars)
  jars.each {|jar| require jar}
end


require_jars Dir.glob(File.join(server_dir, 'tomcat/webapps/pentaho/WEB-INF/lib', '*.jar'))
require_jars Dir.glob(File.join(server_dir, 'tomcat/common/lib', 'postgres*.jar'))


CWM = Java::OrgPentahoPmsCore::CWM
CwmSchemaFactory = Java::OrgPentahoPmsFactory::CwmSchemaFactory
Relationship = Java::OrgPentahoPmsSchema::RelationshipMeta
BusinessModel = Java::OrgPentahoPmsSchema::BusinessModel
BusinessTable = Java::OrgPentahoPmsSchema::BusinessTable
BusinessCategory = Java::OrgPentahoPmsSchema::BusinessCategory
PhysicalColumn = Java::OrgPentahoPmsSchema::PhysicalColumn
PhysicalTable = Java::OrgPentahoPmsSchema::PhysicalTable
PublisherUtil = Java::OrgPentahoPlatformUtilClient::PublisherUtil
SecurityOwner = Java::OrgPentahoPmsSchemaSecurity::SecurityOwner

def load_metadata_xmi(file_path)
  puts "Loading metadata"
  Metadata.new(file_path)
end

class Metadata
  def initialize(metafile)
    FileUtils.rm Dir.glob('mdr.*')
    @schema_factory = CwmSchemaFactory.new    
    @cwm = CWM.get_instance('__tmp_domain__')
    @cwm.importFromXMI metafile
    @meta = @schema_factory.getSchemaMeta(@cwm)
    @cwm.remove_domain
    @cwm = CWM.get_instance('TriSano')
  end

  def writable_database
    @meta.databases.each {|db| return Database.new(db) if db.name =~ /Update Script Connection/}
  end

  def ro_database
    @meta.databases.each {|db| return Database.new(db) unless db.name =~ /Update Script Connection/}
  end

  def update_from_database
    publish writable_database.modified_tables, {
      :success => lambda{ writable_database.clear_modified_tables; puts 'Success!' },
      :failure => lambda{ |result| puts "Failed because #{hash_fail[result]}" },
      :none    => lambda{ puts "No modified tables. Nothing to do" }}
  end

  def hash_fail
    @hash_fail ||= { 
      1 => "file exists", 
      2 => "file add failed",
      3 => "file add successfule",
      4 => "invalid publish password",
      5 => "invalid user credentials"}
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
    relationship.field_from = options[:from].find_business_column("#{options[:from].get_id}_event_id")
    relationship.table_to   = options[:to]
    relationship.field_to   = options[:to].id_column
    relationship.type       = options[:type]
    if trisano_business_model.index_of_relationship(relationship) == -1
      trisano_business_model.add_relationship relationship
    end
  end

  def update_physical_table(table_name)
    pt = find_physical_table view_for(table_name)
    if pt.nil?
      pt = PhysicalTable.new view_for(table_name)
      pt.locale_name 'en_US', table_name.gsub('_', ' ')
      pt.set_database_meta(ro_database.meta)
      pt.set_target_schema('trisano')
      pt.set_target_table view_for(table_name)
      @meta.add_table(pt)
    end
    writable_database.column_names_for(table_name).each do |column_name|
      unless pt.has_column?(column_name)
        pc = PhysicalColumn.new(column_name)
        pc.concept.parent_interface = base_concept
        pc.concept.name = column_name
        pc.locale_name 'en_US', column_name.gsub('_', ' ')
        pc.data_type = column_name.suggest_data_type
        pc.field_type = Java::OrgPentahoPmsSchemaConceptTypesFieldtype::FieldTypeSettings::DIMENSION
        pc.formula = column_name.suggest_formula
        pc.table = pt
        pt.add_physical_column pc
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
        bc.set_id "#{view_for(table_name)}_#{pc.get_id}"
        bc.physical_column = pc
        bc.business_table = table
        table.add_business_column bc unless table.has_column?("#{view_for(table_name)}_#{pc.get_id}")
      end
      yield table
    end
  end

  def update_category(category_name, *tables)
    category = find_business_category(category_name)
    if category.nil?
      category = BusinessCategory.new(category_name)
      secure category
      category.locale_name 'en_US', category_name.gsub('_', ' ')
      trisano_business_model.add_category(category)
    end
    tables.each do |table|
      table.business_columns.each do |column|
        category.add_business_column(column) unless category.has_column?(column.get_id)
      end
    end
  end

  def pentaho_roles
    puts "Getting Pentaho's roles"
    secserv = @meta.securityReference.securityService
    secserv.serviceURL = "#{server_url}/pentaho/ServiceAction?action=SecurityDetails&details=all"
    return secserv.getRoles
  end

  def setup_role_security(model)
    puts "Setting up role-based security"
    rbsm = model.rowLevelSecurity.getRoleBasedConstraintMap

    # Remove existing rule set
    existing_rules = []
    rbsm.keySet.each do |mykey|
      existing_rules.push(mykey)
    end
    existing_rules.each do |rulename|
      rbsm.remove(rulename)
    end

    rbsm.put(Java::OrgPentahoPmsSchemaSecurity::SecurityOwner.new(1, 'Admin'), "1 = 1")

    ro_database.jurisdiction_hash.each do |k, v|
      puts "Jurisdiction: #{k}"
    end
    pentaho_roles.each do |rolename|
      puts "Checking out pentaho role #{rolename}"
      if ro_database.jurisdiction_hash[rolename] == 1 then
        puts "  Found role match on #{rolename}"
        rbsm.put(Java::OrgPentahoPmsSchemaSecurity::SecurityOwner.new(1, rolename), "OR([MorbidityEvents.BC_DW_MORBIDITY_EVENTS_VIEW_INVESTIGATING_JURISDICTION]=\"#{rolename}\" ;  [MorbiditySecondaryJurisdictions.BC_DW_MORBIDITY_SECONDARY_JURISDICTIONS_VIEW_NAME] = \"#{rolename}\")")
      end
    end
  end

  def publish(tables, result_hooks={})
    if tables.empty?
      result_hooks[:none].call if result_hooks[:none]
    else
      puts "Creating business tables and relationships"
      tables.each do |short_name, table_name|
        update_physical_table table_name
        update_business_table table_name do |table|
          secure table
          event_table = table_name =~ /contact/ ? contact_events_table : morbidity_events_table
          create_relationship({ :from => table, 
                                :to   => event_table,
                                :type => "N:1"})
          update_category category_name(short_name), table
        end
      end        
      setup_role_security trisano_business_model
      CwmSchemaFactory.new.store_schema_meta(@cwm, @meta, nil)

      puts "Saving metadata to file"
      File.open('metadata.out', 'w') do |io|
        io << @cwm.getXMI
      end
      FileUtils.cp('metadata.out', 'metadata.xmi')

      puts "Publishing metadata to server"
      files = [Java::JavaIo::File.new('metadata.xmi')].to_java(Java::JavaIo::File)
      result = Java::OrgPentahoPlatformUtilClient::PublisherUtil.publish(publish_url, 'TriSano', files, publisher_password, fs_user, fs_user_password, true)
      if result == Java::OrgPentahoPlatformUtilClient::PublisherUtil::FILE_ADD_SUCCESSFUL
        result_hooks[:success].call(result) if result_hooks[:success]
      else 
        result_hooks[:failure].call(result) if result_hooks[:failure]
      end
    end
  end

  def concept_names
    @meta.concept_names
  end

  def base_concept
    @meta.find_concept('Base')
  end

  def morbidity_events_table
    find_business_table 'MorbidityEvents'
  end

  def contact_events_table
    find_business_table 'ContactEvents'
  end

  def secure(obj)
    obj.concept.add_property security_property
  end

  def rights_mask
    return @rights_mask if @rights_mask
    secref = @meta.get_security_reference
    secref.get_security_service.serviceURL = "#{server_url}/pentaho/ServiceAction?action=SecurityDetails&details=all"
    @rights_mask = secref.find_acl("All").mask
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
    ENV['BI_SERVER_URL'] || 'http://localhost:8080'
  end

  def publish_url
    ENV['BI_PUBLISH_URL'] || (server_url + '/pentaho/RepositoryFilePublisher')
  end

  def publisher_password
    ENV['BI_PUBLISH_PASSWORD'] || 'password'
  end

  def fs_user
    ENV['BI_USER_NAME'] || 'joe'
  end

  def fs_user_password
    ENV['BI_USER_PASSWORD'] || 'password'
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

    def jurisdiction_hash
      if ! @jurisdiction_hash
        rs = query(%{
          SELECT p.name
          FROM trisano.places_view p
          JOIN trisano.places_types_view pt
              ON (p.id = pt.place_id)
          JOIN trisano.codes_view c
              ON (c.id = pt.type_id)
          WHERE c.code_description = 'Jurisdiction'})
        @jurisdiction_hash = {}
        while rs.next
          @jurisdiction_hash[rs.getString(1)] = 1
        end
      end
      return @jurisdiction_hash
    end

    def modified_tables
      rs = query("SELECT short_name, table_name FROM trisano.formbuilder_tables WHERE modified=true ORDER BY short_name;")
      results = []
      while rs.next        
        results << [rs.getString(1), rs.getString(2)]
      end
      results
    end

    def clear_modified_tables
      execute("UPDATE trisano.formbuilder_tables SET modified=false")
    end

    def column_names_for(table_name)
      rs = query("SELECT column_name FROM trisano.formbuilder_columns WHERE formbuilder_table_name='#{table_name}' ORDER BY column_name;")
      results = []
      while rs.next
        results << rs.getString(1)
      end      
      results.empty? ? results : %w(event_id type) + results
    end
  end
end

module ConceptExtension
  def locale_name(locale, name)
    concept.get_property('name').value.locale_string_map[locale] = name
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
  
  def has_column?(column_name)
    !find_business_column(column_name).nil?
  end
end

BusinessCategory.class_eval do
  include ConceptExtension

  def has_column?(column_name)
    !find_business_column(column_name).nil?
  end
end

PhysicalTable.class_eval do
  include ConceptExtension

  def has_column?(column_name)
    !find_physical_column(column_name).nil?
  end
end

PhysicalColumn.class_eval do
  include ConceptExtension
end

String.class_eval do
  def suggest_data_type
    if self == 'event_id'
      return Java::OrgPentahoPmsSchemaConceptTypesDatatype::DataTypeSettings::NUMERIC
    end
    Java::OrgPentahoPmsSchemaConceptTypesDatatype::DataTypeSettings::STRING
  end

  def suggest_formula
    case self
    when 'event_id', 'type': self
    else
      "col_#{self}"
    end
  end
end

if __FILE__ == $0
  meta = load_metadata_xmi(File.expand_path(File.join(File.dirname(__FILE__), 'metadata.xmi')))
  meta.update_from_database
end
