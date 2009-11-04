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

require 'java'
require 'benchmark'
require 'fileutils'
require 'yaml'

def server_dir
  ENV['BI_SERVER_PATH'] || '/usr/local/pentaho/server/biserver-ce'
end

def database_driver_class
  ENV['TRISANO_DB_DRIVER'] || 'org.postgresql.Driver'
end

def database_user
  ENV['TRISANO_DB_USER'] || 'dw_priv_user'
end

def database_password
  ENV['TRISANO_DB_PASSWORD'] || 'dw_priv_user'
end

def database_url
  ENV['TRISANO_JDBC_URL'] || 'jdbc:postgresql://localhost:5432/trisano_warehouse'
end

def require_jars(jars)
  jars.each {|jar| require jar}
end

require_jars Dir.glob(File.join(server_dir, 'tomcat/webapps/pentaho/WEB-INF/lib', '*.jar'))
require_jars Dir.glob(File.join(server_dir, 'tomcat/common/lib', 'postgres*.jar'))

AllTablesGroupName = 'All Formbuilder Tables';
DefaultFieldType = Java::OrgPentahoPmsSchemaConceptTypesFieldtype::FieldTypeSettings::DIMENSION
MaxX = 800

CWM = Java::OrgPentahoPmsCore::CWM
CwmSchemaFactory = Java::OrgPentahoPmsFactory::CwmSchemaFactory
Relationship = Java::OrgPentahoPmsSchema::RelationshipMeta
BusinessModel = Java::OrgPentahoPmsSchema::BusinessModel
BusinessTable = Java::OrgPentahoPmsSchema::BusinessTable
BusinessCategory = Java::OrgPentahoPmsSchema::BusinessCategory
BusinessColumn = Java::OrgPentahoPmsSchema::BusinessColumn
PhysicalColumn = Java::OrgPentahoPmsSchema::PhysicalColumn
PhysicalTable = Java::OrgPentahoPmsSchema::PhysicalTable
PublisherUtil = Java::OrgPentahoPlatformUtilClient::PublisherUtil
SecurityOwner = Java::OrgPentahoPmsSchemaSecurity::SecurityOwner
SchemaMeta = Java::OrgPentahoPmsSchema::SchemaMeta
AggregationSettings = Java::OrgPentahoPmsSchemaConceptTypesAggregation::AggregationSettings
Concept = Java::OrgPentahoPmsSchemaConcept::Concept
ConceptPropertyLocalizedString = Java::OrgPentahoPmsSchemaConceptTypesLocalstring::ConceptPropertyLocalizedString
ConceptPropertyString = Java::OrgPentahoPmsSchemaConceptTypesString::ConceptPropertyString
ConceptPropertyTableType = Java::OrgPentahoPmsSchemaConceptTypesTabletype::ConceptPropertyTableType
ConceptPropertyNumber = Java::OrgPentahoPmsSchemaConceptTypesNumber::ConceptPropertyNumber
DataTypeSettings = Java::OrgPentahoPmsSchemaConceptTypesDatatype::DataTypeSettings
LocalizedStringSettings = Java::OrgPentahoPmsSchemaConceptTypesLocalstring::LocalizedStringSettings
TableTypeSettings = Java::OrgPentahoPmsSchemaConceptTypesTabletype::TableTypeSettings
DatabaseMeta = Java::OrgPentahoDiCoreDatabase::DatabaseMeta
SecurityService = Java::OrgPentahoPmsSchemaSecurity::SecurityService
SecurityReference = Java::OrgPentahoPmsSchemaSecurity::SecurityReference

def db_connection
    props = Java::JavaUtil::Properties.new
    props.setProperty "user", database_user
    props.setProperty "password", database_password
    begin
      conn = create_db_connection.connect database_url, props
      conn.create_statement.execute_update("SET search_path = 'trisano'");
      yield conn
    #rescue
    #  e = $!
    #  puts "Some exception occurred: #{e}"
    #  raise e
    ensure
      conn.close if conn
    end
end

def create_db_connection
    eval("#{database_driver_class}").new
end

def get_query_results(query_string, conn)
    rs = conn.prepare_call(query_string).execute_query
    res = []
    len = rs.getMetaData().getColumnCount()
    while rs.next
      val = {}
      (1..len).each do |i|
        val[rs.getMetaData().getColumnName(i)] = rs.getString(i)
      end
      res << val
    end
    return res
end

def setup_security_reference(meta)
  secref = SecurityReference.new
  secserv = secref.getSecurityService
  secserv.setDetailNameParameter('details')
  secserv.setDetailServiceType(0)
  secserv.setServiceName('SecurityDetails')
  secserv.setUsername('joe')
  secserv.setPassword('password')
  secserv.setProxyHostname('')
  secserv.setProxyPort('')
  secserv.setNonProxyHosts('')
  secserv.setFilename('')
  secserv.serviceURL = "http://127.0.0.1:8080/pentaho/ServiceAction?action=SecurityDetails&details=all"

  meta.setSecurityReference(secref)
end

def role_type
  Java::OrgPentahoPmsSchemaSecurity::SecurityOwner::OWNER_TYPE_ROLE
end

def secure(obj)
  owner = Java::OrgPentahoPmsSchemaSecurity::SecurityOwner.new role_type, "Authenticated"
  security = Java::OrgPentahoPmsSchemaSecurity::Security.new
  security.putOwnerRights owner, -1

  obj.concept.add_property Java::OrgPentahoPmsSchemaConceptTypesSecurity::ConceptPropertySecurity.new('security', security)
end

def pentaho_roles(meta)
  puts "Getting Pentaho's roles"
  secserv = meta.securityReference.securityService
  secserv.serviceURL = "http://127.0.0.1:8080/pentaho/ServiceAction?action=SecurityDetails&details=all"
  res = secserv.getRoles
  raise "Couldn't get Pentaho's roles. Perhaps Pentaho isn't running?" if res.nil?
  return res
end

def setup_role_security(model, dg, meta, juris)
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

  pentaho_roles(meta).each do |rolename|
    puts "Checking out pentaho role #{rolename}"
    if juris[rolename] != nil then
      puts "  Found role match on #{rolename}"
      rbsm.put(Java::OrgPentahoPmsSchemaSecurity::SecurityOwner.new(1, rolename), "OR([dw_morbidity_events_view_#{dg}.dw_morbidity_events_view_investigating_jurisdiction_#{dg}]=\"#{rolename}\" ;  [dw_morbidity_secondary_jurisdictions_view_#{dg}.dw_morbidity_secondary_jurisdictions_view_name_#{dg}] = \"#{rolename}\")")
    end
  end
  model.rowLevelSecurity.set_type(Java::OrgPentahoPmsSchemaSecurity::RowLevelSecurity::Type::ROLEBASED)
  puts "Finished building row-level constraints"
end

def jurisdiction_query
  %{
    SELECT p.name AS name
    FROM trisano.places_view p
    JOIN trisano.places_types_view pt
        ON (p.id = pt.place_id)
    JOIN trisano.codes_view c
        ON (c.id = pt.type_id)
    WHERE c.code_description = 'Jurisdiction'
  }
end

def jurisdiction_hash(conn)
    res = {}
    get_query_results(jurisdiction_query, conn).each do |rs|
      res[rs['name']] = 1
    end
    return res
end

def initialize_model(model, meta)
  model.set_connection meta.find_database('TriSano')
  secure model
  return model
end

def initialize_meta(meta)
  setup_security_reference meta
  dm = DatabaseMeta.new('TriSano', 'POSTGRESQL', 'Native', '127.0.0.1', 'trisano_warehouse', '5432', 'trisano_ro', 'password')
  meta.add_database dm
#  udm = DatabaseMeta.new('Update Script Connection', 'POSTGRESQL', 'Native', '127.0.0.1', 'trisano_warehouse', '5432', 'trisano_su', 'password')
#  meta.add_database udm
  return meta
end

def add_business_columns(bt, meta, category, dg, conn)
  pt = bt.get_physical_table
  get_query_results(columns_query(pt.get_target_table, pt.get_target_schema), conn).each do |bcrow|
    bc = BusinessColumn.new "#{pt.get_id}_#{bcrow['name']}_#{dg}"
#    bc.set_id "#{pt.get_id}_#{bcrow['name']}"
    desc = bcrow['description']
    desc.gsub!(/^col_/, '') if pt.get_target_table =~ /^formbuilder_/
    bc.set_name 'en_US', desc
    bc.set_description 'en_US', desc
    pc = pt.find_physical_column "#{pt.get_id}_#{bcrow['name']}"
    if pc.nil?
      pt.get_physical_columns.each do |a| puts a.get_id end
      raise "Couldn't find physical column '#{pt.get_id}.#{bcrow['name']}' for new business column"
    end
    bc.physical_column = pc
    bc.field_type = DefaultFieldType
    bc.business_table = bt
    bt.add_business_column bc
    if (not category.nil?) and (bcrow['make_category_column'] == 'TRUE')
      category.add_business_column bc
      puts " *** Added business column #{bcrow['name']} to category #{category.get_name 'en_US'}"
    end

  end
end

def business_table_query(disease_group)
      query = "SELECT business_table_name, physical_table_name, table_description, make_category, order_num FROM ("
      if disease_group != 'TriSano'
        query += %{
        SELECT
            0 AS order_num,
            ft.short_name AS business_table_name,
            ft.short_name AS table_description,
            ft.table_name || '_view' AS physical_table_name,
            'TRUE' AS make_category
        FROM trisano.formbuilder_tables ft
          JOIN trisano.forms_view f ON (ft.short_name = f.short_name)
          JOIN trisano.form_elements_view fe ON (f.id = fe.form_id)
          JOIN trisano.questions_view q ON (q.form_element_id = fe.id)
          JOIN trisano.answers_view a ON (a.question_id = q.id)
          JOIN trisano.events_view e ON (e.id = a.event_id)
          JOIN trisano.disease_events_view de ON (de.event_id = e.id)
          JOIN trisano.avr_groups_diseases_view adg
            ON (adg.disease_id = de.disease_id)
          JOIN trisano.avr_groups_view ag
            ON (ag.id = adg.avr_group_id AND (ag.name = '#{disease_group}' OR '#{disease_group}' = 'All tables'))
          WHERE a.text_answer IS NOT NULL AND a.text_answer != '' -- AND (
--            ft.disease_groups IS NULL OR
--            NOT ('#{disease_group}' = ANY(ft.disease_groups))
--           )
          GROUP BY ft.short_name, ft.table_name
        UNION

        }
      end
      query += %{
        SELECT order_num, table_name AS business_table_name, table_description, relname AS physical_table_name,
        CASE
            WHEN make_category THEN 'TRUE'
            ELSE 'FALSE'
        END AS make_category
        FROM trisano.core_tables c JOIN pg_class pgc
            ON (pgc.oid = c.target_table::regclass)
        ) f ORDER BY order_num != 0 DESC NULLS FIRST, order_num, business_table_name
-- LIMIT 25 -- limitline
      }
end

def add_business_tables(model, meta, disease_group, dg, conn)
  x = 0
  y = 0
  get_query_results(business_table_query(disease_group), conn).each do |btrow|
    pt = meta.find_physical_table btrow['physical_table_name']
    raise "Couldn't find physical table #{btrow['physical_table_name']}" if pt.nil?
    #puts "Creating business table #{btrow['business_table_name']}_#{dg}"
    bt = BusinessTable.new "#{btrow['business_table_name']}_#{dg}", pt
    bt.set_name 'en_US', btrow['business_table_name']
    #bt.set_description 'en_US', btrow['table_description']
    x += 50
    if x > MaxX
      y += 120
      x = 0
    end
    bt.set_location x, y
    secure bt

    # Build business categories, too
    if btrow['make_category'] == 'TRUE'
      puts "Building business category for '#{btrow['table_description']}'"
      bc = BusinessCategory.new "#{btrow['table_description']}_#{dg}"
      bc.set_name 'en_US', btrow['table_description']
      bc.set_root_category false
    else
      bc = nil
    end

    add_business_columns bt, meta, bc, dg, conn
    model.add_business_table bt
    unless bc.nil?
      secure bc
      model.get_root_category.add_business_category bc
    end
    
    if btrow['physical_table_name'] =~ /^formbuilder/
      rel = Relationship.new
      rel.table_from = bt
      f = nil
      if btrow['physical_table_name'] =~ /_contacts_\d+_view/
        f = "dw_contact_events_view"
      else
        f = "dw_morbidity_events_view"
      end
      rel.table_to = model.find_business_table "#{f}_#{dg}"
      if rel.table_to.nil?
        model.get_business_tables.each do |a| puts a.get_name 'en_US' end
        raise "Couldn't find events table for relationship with #{btrow['physical_table_name']}" if f.nil?
      end
      rel.field_to = rel.table_to.find_business_column 'en_US', "#{f}_id_#{dg}"
      if rel.field_to.nil?
        f.get_business_columns.each do |a| puts "   #{a.get_id}" end
        raise "Couldn't find field_to column #{f}_#{dg}.#{f}_id_#{dg}"
      end
      rel.table_from = bt
      rel.field_from = bt.find_business_column 'en_US', 'event_id'
      raise "Couldn't find field_from column #{bt.get_id}.event_id" if rel.field_from.nil?
      rel.type = 'N:1'
      model.add_relationship rel
    end
  end
end

def disease_group_query
  return 'SELECT DISTINCT name FROM trisano.avr_groups_view'
end

def create_models(meta, conn)
  groups = [] << 'Trisano' << 'All tables'
  groups.concat get_query_results(disease_group_query, conn).map { |a| a['name'] }
  i = 0
  groups.each do |disease_group|
    puts "Processing disease group #{disease_group}"
    model = BusinessModel.new disease_group
    initialize_model model, meta
    root_bc = BusinessCategory.new
    root_bc.set_root_category true
    model.set_root_category root_bc
    i += 1
    add_business_tables model, meta, disease_group, "DG#{i}", conn
    create_relationships model, "DG#{i}", conn
    setup_role_security model, "DG#{i}", meta, jurisdiction_hash(conn)
    meta.add_model(model)
  end
end

def columns_query(tablename, schemaname)
# From Pentaho's DataTypeSettings.java:
# public static final int DATA_TYPE_STRING    = 1;                                                                                           
# public static final int DATA_TYPE_DATE      = 2;                                                                                           
# public static final int DATA_TYPE_BOOLEAN   = 3;                                                                                           
# public static final int DATA_TYPE_NUMERIC   = 4;                                                                                           
# public static final int DATA_TYPE_BINARY    = 5;                                                                                           
# public static final int DATA_TYPE_IMAGE     = 6;                                                                                           
# public static final int DATA_TYPE_URL       = 7;                                                                                           
  if tablename =~ /formbuilder_.*/
    return %{
        SELECT
            attname AS name,
            attname AS description,
            attname AS target_column,
            regexp_replace(relname || '_' || attname, '[[:space:]]', '_') AS id,
            CASE
                WHEN format_type(atttypid, atttypmod) IN ('bigint', 'integer', 'numeric') THEN 4
                WHEN format_type(atttypid, atttypmod) ~ 'timestamp' THEN 2
                WHEN format_type(atttypid, atttypmod) = 'date' THEN 2
                WHEN format_type(atttypid, atttypmod) = 'boolean' THEN 3
                WHEN format_type(atttypid, atttypmod) = 'bytea' THEN 5
                ELSE 1
            END AS data_type,
            CASE
                WHEN attname IN ('event_id', 'type') THEN 'FALSE'
                ELSE 'TRUE'
            END AS make_category_column
        FROM
            pg_attribute pga
            JOIN pg_class pgc ON (pgc.oid = pga.attrelid)
        WHERE
            relname = '#{tablename}' AND
            relnamespace = (
                SELECT oid FROM pg_namespace WHERE nspname = '#{schemaname}'
            )
        ORDER BY attnum
    }
  else
    return %{
        SELECT
            column_name AS name, 
            column_description AS description,
            pga.attname AS target_column,
            regexp_replace(relname || '_' || attname, '[[:space:]]', '_') AS id,
            CASE
                WHEN format_type(atttypid, atttypmod) IN ('bigint', 'integer', 'numeric') THEN 4
                WHEN format_type(atttypid, atttypmod) ~ 'timestamp' THEN 2
                WHEN format_type(atttypid, atttypmod) = 'date' THEN 2
                WHEN format_type(atttypid, atttypmod) = 'boolean' THEN 3
                WHEN format_type(atttypid, atttypmod) = 'bytea' THEN 5
                ELSE 1
            END AS data_type,
            CASE
                WHEN make_category_column THEN 'TRUE'
                ELSE 'FALSE'
            END AS make_category_column
        FROM
            trisano.core_columns c
            JOIN pg_attribute pga ON (c.target_column = pga.attname AND c.target_table::regclass = pga.attrelid) 
            JOIN pg_class pgc ON (pgc.oid = pga.attrelid)
        WHERE
            relname = '#{tablename}' AND
            relnamespace = (
                SELECT oid FROM pg_namespace WHERE nspname = '#{schemaname}'
            )
        ORDER BY attnum
    }
  end
end

def add_physical_columns(pt, conn)
  i = 0
  get_query_results(columns_query(pt.get_target_table, pt.get_target_schema), conn).each do |pcrow|
    i = 1
    pc = PhysicalColumn.new pcrow['id']
    desc = (pcrow['description'] == '' ? pcrow['id'] : pcrow['description'])
    desc.gsub!(/^col_/, '') if pt.get_target_table =~ /^formbuilder_/
    pc.set_name 'en_US', desc
    pc.set_description 'en_US', desc
    pc.set_data_type DataTypeSettings.new(pcrow['data_type'].to_i)
    pc.field_type = Java::OrgPentahoPmsSchemaConceptTypesFieldtype::FieldTypeSettings::DIMENSION
    pc.table = pt
    pc.formula = pcrow['target_column']
    pc.set_relative_size -1
    pc.set_aggregation_type AggregationSettings.new(0)
    pc.set_hidden false
#    pc.set_exact true
    pt.add_physical_column pc
  end
  raise "Didn't add any physical columns for physical table #{pt.get_target_schema}.#{pt.get_target_table}" if i == 0
end

def physical_table_query
  return %{
    SELECT id, name, description, target_table, target_namespace FROM  (
    SELECT
        order_num,
        table_name AS id,
        table_name AS name,
        table_description AS description,
        relname AS target_table,
        nspname AS target_namespace
    FROM
        trisano.core_tables
        JOIN pg_class ON (pg_class.oid = target_table::regclass)
        JOIN pg_namespace pgn ON (pgn.oid = relnamespace)

    UNION

    SELECT
        0 AS order_num,
        table_name || '_view' AS id,
        short_name AS name,
        short_name AS description,
        table_name || '_view' AS target_table,
        'trisano' AS target_namespace
    FROM
        trisano.formbuilder_tables
    ) f ORDER BY order_num != 0 DESC NULLS FIRST, order_num, name
  }
end

def create_physical_tables(meta, conn)
  get_query_results(physical_table_query, conn).each do |ptrow|
    puts "Creating new physical table: #{ptrow['name']}"
    pt = PhysicalTable.new ptrow['id']
    pt.set_name 'en_US', ptrow['name']
    pt.set_description 'en_US', ptrow['description']
    pt.set_database_meta meta.find_database 'TriSano'
    pt.set_target_table ptrow['target_table']
    pt.set_target_schema ptrow['target_namespace']
    pt.set_relative_size -1
    pt.set_table_type TableTypeSettings.new(0)
    add_physical_columns pt, conn
    meta.add_table pt
  end
end

def relationships_query
    return %{
        SELECT
            fromtab.relname || '_' || from_column AS fromcol,
            fromtab.relname AS fromtab,
            totab.relname || '_' || to_column AS tocol,
            totab.relname AS totab,
            relation_type AS type
        FROM
            trisano.core_relationships r
            JOIN pg_class fromtab
                ON (r.from_table::regclass = fromtab.oid)
            JOIN pg_class totab
                ON (r.to_table::regclass = totab.oid)
    }
end

def create_relationships(model, dg, conn)
  get_query_results(relationships_query, conn).each do |rel|
    r = Relationship.new
    puts "Creating relationship for #{rel['fromtab']}.#{rel['fromcol']} to #{rel['totab']}.#{rel['tocol']}"
    r.table_from = model.find_business_table('en_US', rel['fromtab'])
    raise "Can't have a nil business table" if r.table_from.nil?
    r.field_from = r.table_from.find_business_column "#{rel['fromcol']}_#{dg}"
    raise "Can't have a nil from column (looked for column #{rel['fromcol']})" if r.field_from.nil?
    r.table_to = model.find_business_table('en_US', rel['totab'])
    raise "Can't have a nil business table" if r.table_to.nil?
    r.field_to = r.table_to.find_business_column "#{rel['tocol']}_#{dg}"
    raise "Can't have a nil to column (looked for column #{rel['tocol']})" if r.field_from.nil?
    r.type = rel['type']
    model.add_relationship r
  end
end

def save_metadata(meta, filename)
  cwm = CWM.get_instance('test')
  CwmSchemaFactory.new.store_schema_meta(cwm, meta, nil)
  puts "Writing out new XMI file"
  File.open(filename, 'w') do |io|
    io << cwm.getXMI
  end
end

if __FILE__ == $0
  FileUtils.rm Dir.glob('mdr.*'), :force => true
  FileUtils.rm 'metadata.xmi', :force => true

  meta = initialize_meta SchemaMeta.new

  db_connection do |conn|
    # Create physical tables, and all physical columns
    create_physical_tables meta, conn
    create_models meta, conn
  end


  save_metadata meta, 'metadata.out'
  FileUtils.cp('metadata.out', 'metadata.xmi')
end
