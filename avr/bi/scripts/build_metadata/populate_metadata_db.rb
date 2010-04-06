# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

AllTablesGroupName = 'All Formbuilder Tables';

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
ConceptPropertyLocalizedString = Java::OrgPentahoPmsSchemaConceptTypesLocalstring::ConceptPropertyLocalizedString
ConceptPropertyString = Java::OrgPentahoPmsSchemaConceptTypesString::ConceptPropertyString
ConceptPropertyTableType = Java::OrgPentahoPmsSchemaConceptTypesTabletype::ConceptPropertyTableType
ConceptPropertyNumber = Java::OrgPentahoPmsSchemaConceptTypesNumber::ConceptPropertyNumber

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

  def trisano_business_model
    if ! defined? @trisano_business_model
      @trisano_business_model = @meta.find_model('TriSano')
      setup_role_security @trisano_business_model
    end
    return @trisano_business_model
  end

  def write_physical_column(c, tbl)
    puts "INSERT INTO columns VALUES ('#{tbl}', '#{c.get_id}', '#{c.get_display_name('en_US')}', '#{c.get_aggregation_type_desc}', '#{c.get_formula}', '#{c.get_model_element_description}', '#{c.get_relative_size}', '#{c.is_attribute_field}', '#{c.is_dimension_field}', '#{c.is_dimension_table}', '#{c.is_exact}', '#{c.is_fact_field}', '#{c.is_fact_table}', '#{c.is_hidden}');"
    agg = c.get_aggregation_type
    puts "INSERT INTO column_aggregation_types VALUES ('#{tbl}', '#{c.get_id}', '#{agg.get_code}', '#{agg.get_description}', '#{agg.get_type}');"
    puts "TODO: c.get_concept"
    puts "TODO: c.get_field_type"
    puts "TODO: c.get_data_type"  # Likely this is what needs changing for acuity to work
    if c.get_mask != nil
      puts "XXX XXX XXX non-nil column model_element_description XXX XXX XXX"
    end
    if c.getSecurity.getOwners != nil and c.getSecurity.getOwners.length != 0
      puts "XXX XXX XXX non-nil owners list in #{tbl} #{c.get_display_name('en_US')} security"
      c.getSecurity.getOwners.each do |a| puts a end
    end
    s = c.get_row_level_security
    if s.is_global? or s.is_role_based? 
      puts "XXX XXX XXX non-empty role-based security map on table #{tbl} #{c.get_display_name('en_US')}"
    end
  end

  def write_physical_table(t) 
    nm = t.get_name('en_US')
    puts "INSERT INTO tables VALUES ('#{t.get_id}', '#{nm}', '#{t.get_aggregation_type_desc}', '#{t.get_data_type.get_type}', '#{t.get_data_type.get_length}', '#{t.get_data_type.get_precision}', '#{t.get_data_type.get_description}', '#{t.get_description('en_US')}', '#{t.get_display_name('en_US')}', '#{t.get_field_type.get_code}', '#{t.get_field_type_desc}', '#{t.get_formula}', '#{t.get_model_element_description}', '#{t.get_relative_size}', '#{t.isAttributeField}', '#{t.isDimensionField}', '#{t.isDimensionTable}', '#{t.is_exact}', '#{t.is_fact_field}', '#{t.is_fact_table}', '#{t.is_hidden}');"
    if t.has_aggregate?
      puts "XXX XXX XXX This table has an aggregate XXX XXX XXX"
    end
    if t.get_field_type.get_code != "Other"
      puts "XXX XXX XXX Non-'other' field type XXX XXX XXX"
    end
    if t.get_mask != nil
      puts "XXX XXX XXX Non-nil table mask XXX XXX XXX"
    end
    if t.get_security.get_owners != nil and t.getSecurity.getOwners.length != 0
      puts "XXX XXX XXX non-nil owners list in #{t.get_id} security"
    end
    s = t.get_row_level_security
    if s.is_global? or s.is_role_based? 
      puts "XXX XXX XXX non-empty role-based security map on table #{t.get_id}"
    end
    agg = t.get_aggregation_type
    puts "INSERT INTO table_aggregation_types VALUES ('#{t.get_id}', '#{agg.get_code}', '#{agg.get_description}', '#{agg.get_type}');"
    con = t.get_concept
    puts "INSERT INTO table_concepts VALUES ('#{t.get_id}', '#{con.get_name}', '#{con.get_description('en_US')}');"
    con.get_child_property_ids.each do |cpi|
      cp = con.get_child_property(cpi)
      if cp.is_a? ConceptPropertyLocalizedString then
        val = cp.get_value.get_string('en_US')
      elsif cp.is_a? String then
        val = cp
      elsif cp.is_a? ConceptPropertyString then
        val = cp.to_string
      elsif cp.is_a? ConceptPropertyTableType then
        val = cp.get_value.get_description
        if val != "Other"
          puts "XXX XXX XXX Something other than \"Other\" XXX XXX"
        end
      elsif cp.is_a? ConceptPropertyNumber then
        val = cp.get_value
        if val == nil
          val = ""
        else
          puts "XXX XXX XXX XXX  non-nil ConceptPropertyNumber"
        end
      else
        val = "I dunno how to handle these yet"
      end
      puts "INSERT INTO table_concept_child_properties VALUES ('#{t.get_id}', '#{con.get_name}', '#{cpi}', '#{val}', '#{cp.get_type}');"
    end
    t.get_physical_columns.each do |a| write_physical_column a, t.get_id end
  end

  def write_relationship(rel)
    puts "INSERT INTO relationships (table_from, field_from, table_to, field_to, type_desc) VALUES ('#{rel.get_table_from.get_id}', '#{rel.get_field_from.get_id}', '#{rel.get_table_to.get_id}', '#{rel.get_field_to.get_id}', '#{rel.get_type_desc}');"
  end

  def write_business_column(bcol)
    puts "INSERT INTO business_columns VALUES ('#{bcol.get_id}', '#{bcol.get_physical_column.get_table.get_id}', '#{bcol.get_physical_column.get_id}');"
  end

  def write_business_table(tbl)
    puts "INSERT INTO business_tables VALUES ('#{tbl.get_id}', '#{tbl.get_physical_table.get_id}', '#{tbl.get_name('en_US')}');"
    tbl.get_business_columns.each do |bcol|
      write_business_column bcol
    end
  end

  def write_category_column(cat, c)
    puts "INSERT INTO category_columns (category_name, business_table, business_column) VALUES ('#{cat.get_name('en_US')}', '#{c.get_business_table.get_id}', '#{c.get_id}');"
  end

  def write_category(cat)
    puts "INSERT INTO categories VALUES ('#{cat.get_name('en_US')}', '#{cat.get_display_name('en_US')}');"
    cat.get_business_columns.each do |c| write_category_column cat, c end
  end

  def write_to_database
    # Write physical tables
    @meta.get_tables.each do |a| write_physical_table a end
    # Note to self -- relationships are a property of business tables, and
    # thus of business models, not of physical tables
    trisano_business_model.get_business_tables.each do |tbl| write_business_table tbl end
    trisano_business_model.get_relationships.each do |rel| write_relationship rel end
    trisano_business_model.get_root_category.get_business_categories.each do |cat| write_category cat end
  end

  def update_from_database
    ro_database.disease_groups.each do |disease_group|
      model = @meta.find_model(disease_group)
      if model == nil
        puts "Creating new business model for disease group #{disease_group}"
        # See src/org/pentaho/pms/ui/MetaEditor.java, line 2506 for API examples
        model = BusinessModel.new(disease_group)
        trisano_business_model.get_business_tables.each do |t|
          model.add_business_table t
        end
        trisano_business_model.get_relationships.each do |t|
          model.add_relationship t
        end
        trisano_business_model.get_notes.each do |t|
          model.add_note t
        end
        # For category examples, see:
        # CwmSchemaFactory.java line 1371

        # Clone() is important. Otherwise, each group has the *same* category
        # object. Then, each group has all the same categories. Oddly enough,
        # though, the categories are empty except for the diseases in that
        # group.
        model.set_root_category trisano_business_model.get_root_category.clone()

        model.set_connection trisano_business_model.get_connection
        model.set_security(trisano_business_model.get_security.clone())
        @meta.add_model(model)
      end

      puts "Processing disease group #{disease_group}"
      tables = writable_database.modified_tables(disease_group == AllTablesGroupName ? nil : disease_group)
      create_tables tables, model, {
        :success => lambda{ puts 'Success!' },
        :none    => lambda{ puts "No modified tables." }}
      writable_database.update_disease_groups_col tables.join("','"), disease_group

      setup_role_security model
    end

    writable_database.clear_modified_tables

    publish ({
      :success => lambda{ puts 'Success!' },
      :failure => lambda{ 
        |result| puts "*** ERROR PUBLISHING METADATA *** Publishing failed because #{hash_fail[result]}" 
        Process.exit(1)
      }})
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

  def find_business_table(table_name, model)
    model.find_business_table(table_name)
  end

  def find_business_category(category_name, model)
    model.root_category.business_categories.each do |bc|
      return bc if bc.get_id == category_name
    end
  end

  def view_for(table_name)
    "#{table_name}_view"
  end

  def create_relationship(options, model)
    relationship = Relationship.new
    relationship.table_from = options[:from]
    relationship.field_from = options[:from].find_business_column("#{options[:from].get_id}_event_id")
    relationship.table_to   = options[:to]
    relationship.field_to   = options[:to].id_column
    relationship.type       = options[:type]
    if model.index_of_relationship(relationship) == -1
      model.add_relationship relationship
    end
  end

  def update_physical_table(table_name)
    pt = find_physical_table view_for(table_name)
    if pt.nil?
      puts "   Creating new physical table"
      pt = PhysicalTable.new view_for(table_name)
      pt.locale_name 'en_US', table_name.gsub('_', ' ')
      pt.set_database_meta(ro_database.meta)
      pt.set_target_schema('trisano')
      pt.set_target_table view_for(table_name)
      @meta.add_table(pt)
    else
      puts "   Physical table already exists"
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

  def update_business_table(table_name, model)
    pt = find_physical_table view_for(table_name)
    unless pt.nil?
      table = find_business_table view_for(table_name), model
      if table.nil?
        puts "      Creating new business table #{table_name}"
        table = Java::OrgPentahoPmsSchema::BusinessTable.new view_for(table_name), pt
        model.add_business_table table
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

  def update_category(category_name, model, *tables)
    category = find_business_category(category_name, model)
    if category.nil?
      category = BusinessCategory.new(category_name)
      secure category
      category.locale_name 'en_US', category_name.gsub('_', ' ')
      model.add_category(category)
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
    model.rowLevelSecurity.set_type(Java::OrgPentahoPmsSchemaSecurity::RowLevelSecurity::Type::ROLEBASED)
  end

  def publish(result_hooks={})
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

  def create_tables(tables, model, result_hooks={})
    if tables.empty?
      result_hooks[:none].call if result_hooks[:none]
    else
      puts "Creating business tables and relationships"
      tables.each do |short_name, table_name|
        puts "Adding table #{short_name} to disease group model"
        update_physical_table table_name
        update_business_table table_name, model do |table|
          secure table
          event_table = table_name =~ /contact/ ? contact_events_table(model) : morbidity_events_table(model)
          create_relationship({ :from => table,
                                :to   => event_table,
                                :type => "N:1"}, model)
          update_category category_name(short_name), model, table
        end
      end
      result_hooks[:success].call if result_hooks[:success]
    end
  end

  def concept_names
    @meta.concept_names
  end

  def base_concept
    @meta.find_concept('Base')
  end

  def morbidity_events_table(model)
    find_business_table 'MorbidityEvents', model
  end

  def contact_events_table(model)
    find_business_table 'ContactEvents', model
  end

  def secure(obj)
    obj.concept.add_property security_property
  end

  def rights_mask
    return @rights_mask if @rights_mask
    secref = @meta.get_security_reference
    secref.get_security_service.serviceURL = "#{server_url}/pentaho/ServiceAction?action=SecurityDetails&details=all"
    secref.get_security_service.set_username(fs_user)
    secref.get_security_service.set_password(fs_user_password)
    acl = secref.find_acl("All")
    if acl == nil
      raise "Couldn't get ACL from Pentaho. Is Pentaho running, at #{server_url}? Perhaps the username (#{fs_user}) or the password are wrong."
    else
      @rights_mask = acl.mask
    end
    @rights_mask
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

    def update_disease_groups_col(tables, disease_group)
      execute( %{
        UPDATE trisano.formbuilder_tables
        SET disease_groups =
            CASE
                WHEN disease_groups IS NULL THEN ARRAY['#{disease_group}']
                ELSE disease_groups || '#{disease_group}'::text
            END
        WHERE short_name IN ('#{tables}')
        AND (disease_groups IS NULL OR NOT ('#{disease_group}' = ANY(disease_groups)))
      })
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

    def get_query_results(query_string)
      rs = query(query_string)
      while rs.next
        yield rs
      end
    end

    def disease_groups
      return @disease_groups if @disease_groups
      @disease_groups = []
      get_query_results 'SELECT DISTINCT name FROM trisano.avr_groups_view' do
        |rs|
        a = rs.getString(1)
        @disease_groups << a
      end
      @disease_groups << AllTablesGroupName;
    end

    def jurisdiction_hash
      return @jurisdiction_hash if @jurisdiction_hash
      @jurisdiction_hash = {}
      get_query_results %{
          SELECT p.name
          FROM trisano.places_view p
          JOIN trisano.places_types_view pt
              ON (p.id = pt.place_id)
          JOIN trisano.codes_view c
              ON (c.id = pt.type_id)
          WHERE c.code_description = 'Jurisdiction'} do |rs|
        @jurisdiction_hash[rs.getString(1)] = 1
      end
      @jurisdiction_hash
    end

    def modified_tables(disease_group=nil)
      # Get all formbuilder tables that are part of this disease group.

      # Note on the disease_groups column: The tables required to provide all
      # relevant formbuilder information for a particular disease group might
      # change just by someone filling out an old form for a new disease, or by
      # a disease group changing. So adding forms to the schema based only on
      # the 'modified' column isn't adequate. Instead, we track which disease
      # groups use this form currently.  If we find a form with answers for a
      # disease in this disease group where the disease_groups, and for that
      # form short name, modified is true or where the current disease group
      # isn't represented in the disease_groups column, we add it to the schema
      # for this disease group

      modified_tables = []
      query = "SELECT ft.short_name, ft.table_name FROM trisano.formbuilder_tables ft "
      if disease_group
        query += %{
          JOIN trisano.forms_view f ON (ft.short_name = f.short_name)
          JOIN trisano.form_elements_view fe ON (f.id = fe.form_id)
          JOIN trisano.questions_view q ON (q.form_element_id = fe.id)
          JOIN trisano.answers_view a ON (a.question_id = q.id)
          JOIN trisano.events_view e ON (e.id = a.event_id)
          JOIN trisano.disease_events_view de ON (de.event_id = e.id)
          JOIN trisano.avr_groups_diseases_view adg
            ON (adg.disease_id = de.disease_id)
          JOIN trisano.avr_groups_view ag
            ON (ag.id = adg.avr_group_id AND ag.name = '#{disease_group}')
          WHERE a.text_answer IS NOT NULL AND a.text_answer != '' AND (
            ft.modified OR
            ft.disease_groups IS NULL OR
            NOT ('#{disease_group}' = ANY(ft.disease_groups))
          )
          GROUP BY ft.short_name, ft.table_name
        }
      else
        query += " WHERE ft.modified"
      end
      query += " ORDER BY ft.short_name;"
      get_query_results query do |rs|
        modified_tables << [rs.getString(1), rs.getString(2)]
      end
      modified_tables.each do |a|
        puts "Adding table #{a} for disease group #{disease_group}"
      end
      modified_tables
    end

    def clear_modified_tables
      execute("UPDATE trisano.formbuilder_tables SET modified=false")
    end

    def column_names_for(table_name)
      results = []
      get_query_results "SELECT column_name FROM trisano.formbuilder_columns WHERE formbuilder_table_name='#{table_name}' ORDER BY column_name;" do |rs|
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
  meta.write_to_database
end
