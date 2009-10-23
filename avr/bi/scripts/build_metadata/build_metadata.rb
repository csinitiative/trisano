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
      yield conn
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
      val = []
      (1..len).each do |i|
        val << rs.getString(i)
      end
      res << val
    end
    return res
end

def all_tables
  tbls = []
  get_query_results "SELECT tablename, table_id, table_friendly_name, table_description  FROM trisano.metadata_tables" do |rs|
    tbls << [rs.getString(1), rs.getString(2), rs.getString(3), rs.getString(4)]
  end
  return tbls
end

def table_columns(tbl)
  cols = []
  get_query_results "SELECT columnname, column_id, column_desc FROM trisano.metadata_columns WHERE tablename = '#{tbl}'" do |rs|
    cols << [rs.getString(1), rs.getString(2), rs.getString(3)]
  end
  return cols
end

def all_relationships
  rels = []
  get_query_results "SELECT first_table, first_column, second_table, second_column, relationship_type FROM trisano.metadata_relationships" do |rs|
    rels << [rs.getString(1), rs.getString(2), rs.getString(3), rs.getString(4)]
  end
  return rels
end

def all_tables
  return "SELECT table_id, table_name, aggregation_type, length, precision, data_type_description, description, display_name FROM tables"
end

def table_concepts(tbl)
  return "SELECT concept_name, concept_description FROM table_concepts WHERE table_id = '#{tbl}'"
end

def table_child_concepts(tbl, conc)
  return "SELECT child_concept_name, child_concept_value, child_concept_type FROM table_concept_child_properties WHERE table_id = '#{tbl}' AND concept_name = '#{conc}'"
end

def business_tables(tbl)
  return "SELECT table_id, display_name FROM business_tables WHERE physical_table_id = '#{tbl}' ORDER BY order_num"
end

def columns(tbl)
  return "SELECT column_id, column_display_name, aggregation_type_desc, formula, relative_size FROM columns WHERE table_id = '#{tbl}'"
end

def column_aggregation_types(tbl, col)
  return "SELECT agg_type FROM column_aggregation_types WHERE table_id = '#{tbl}' AND column_id = '#{col}'"
end

def business_columns(pt, pc)
  puts "Finding business columns for table '#{pt}' and column '#{pc}'"
  return "SELECT business_column_id FROM business_columns WHERE physical_column_id = '#{pc}' AND physical_table_id = '#{pt}'"
end

def relationships
  return "SELECT table_from, field_from, table_to, field_to, type_desc FROM relationships"
end

def category_columns(cat)
  return "SELECT business_table, business_column FROM category_columns WHERE category_name = '#{cat}' ORDER BY col_order ASC"
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
  return res
end

def setup_role_security(model, meta, juris)
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
      rbsm.put(Java::OrgPentahoPmsSchemaSecurity::SecurityOwner.new(1, rolename), "OR([MorbidityEvents.BC_DW_MORBIDITY_EVENTS_VIEW_INVESTIGATING_JURISDICTION]=\"#{rolename}\" ;  [MorbiditySecondaryJurisdictions.BC_DW_MORBIDITY_SECONDARY_JURISDICTIONS_VIEW_NAME] = \"#{rolename}\")")
    end
  end
  model.rowLevelSecurity.set_type(Java::OrgPentahoPmsSchemaSecurity::RowLevelSecurity::Type::ROLEBASED)
  puts "Finished building row-level constraints"
end

def jurisdiction_query
  %{
    SELECT p.name
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
      res[rs[0]] = 1
    end
    return res
end

if __FILE__ == $0
  FileUtils.rm Dir.glob('mdr.*'), :force => true
  FileUtils.rm 'my_metadata.xmi', :force => true

  meta = SchemaMeta.new
  setup_security_reference meta

  model = BusinessModel.new('TriSano')
  secure model
  dm = DatabaseMeta.new('TriSano', 'POSTGRESQL', 'Native', '127.0.0.1', 'trisano_warehouse', '5432', 'trisano_ro', 'password')
  meta.add_database dm
  model.set_connection dm
  udm = DatabaseMeta.new('Update Script Connection', 'POSTGRESQL', 'Native', '127.0.0.1', 'trisano_warehouse', '5432', 'trisano_su', 'password')
  meta.add_database udm
  db_connection do |conn|    #  0          1          2                 3       4           5                      6          7
    get_query_results(all_tables, conn).each do |tbl|
        puts "Creating new physical table #{tbl[0]} #{tbl[1]} #{tbl[6]} #{tbl[7]}"
        pt = PhysicalTable.new tbl[0]
        pt.set_name 'en_US', tbl[7]
        pt.set_description 'en_US', tbl[6]
        pt.set_database_meta dm
        dts = DataTypeSettings.new(tbl[2].to_i)
        dts.set_length(tbl[3].to_f)
        dts.set_precision(tbl[4].to_f)
        pt.set_data_type(dts)
        pt.set_target_table tbl[1]
        get_query_results(table_concepts(tbl[0]), conn).each do |conc|
          con = Concept.new(conc[0])
          con.set_description('en_US', conc[1])
          get_query_results(table_child_concepts(tbl[0], conc[0]), conn).each do |cc|
            if cc[2] =~ /Localized String/
              l = LocalizedStringSettings.new
              l.setLocaleString('en_US', cc[1])
              con.addProperty(ConceptPropertyLocalizedString.new(cc[0], l))
            elsif cc[2] =~ /TableType/
              con.addProperty(ConceptPropertyTableType.new(cc[0], TableTypeSettings.new(0)))
            elsif cc[2] =~ /String/
              con.addProperty(ConceptPropertyString.new(cc[0], cc[1]))
            elsif cc[2] =~ /Numeric Value/
              if cc[1].to_i
                con.addProperty(ConceptPropertyNumber.new(cc[0], cc[1].to_i))
              else
                con.addProperty(ConceptPropertyNumber(cc[0], 0))
              end
            else
              raise "Can't figure out what to do with table property type #{cc[2]}"
            end
          end
          pt.setConcept(con)
        end

        bus_tables = []
        get_query_results(business_tables(tbl[0]), conn).each do |btbl|
          puts "Creating new business table : #{btbl[0]}"
          bt = BusinessTable.new btbl[0], pt
          puts "Setting table name #{btbl[1]}"
          bt.set_name 'en_US', btbl[1]
          secure bt
          bus_tables << bt
        end
        get_query_results(columns(tbl[0]), conn).each do |col|
          puts "Creating physical column #{col[0]} " + col[0].gsub(/^PC_/, 'BC_')
          pc = PhysicalColumn.new(col[0])
          pc.set_name 'en_US', col[1]
# XXX -   make this smarter
          pc.data_type = Java::OrgPentahoPmsSchemaConceptTypesDatatype::DataTypeSettings::STRING
          pc.field_type = Java::OrgPentahoPmsSchemaConceptTypesFieldtype::FieldTypeSettings::DIMENSION
          pc.table = pt
          pc.formula = col[3]
          pc.set_relative_size(col[4].to_i)
          ag_type = nil
          get_query_results(column_aggregation_types(tbl[0], col[0]), conn).each do |agtyp|
            ag_type = agtyp[0].to_i
            break
          end
          pt.set_aggregation_type(AggregationSettings.new(ag_type)) unless ag_type.nil?
          pt.add_physical_column pc

          i = 0
          get_query_results(business_columns(pc.get_table.get_id, pc.get_id), conn).each do |bcid|
            i += 1
            bc = BusinessColumn.new
            bc.set_id bcid[0]
            bc.physical_column = pc
            bc.field_type = DefaultFieldType
            bus_tables.each do |bt|
              puts "Adding column #{bcid[0]} to business table #{bt.get_id}"
              bc.business_table = bt
              bt.add_business_column bc
            end
          end
          raise "Added #{i} business columns for physical column #{pc.get_table.get_id}.#{pc.get_id}" if i > 1 or i == 0
        end
        bus_tables.each do |bt|
          model.add_business_table bt
        end
        meta.add_table(pt)
    end

    get_query_results(relationships, conn).each do |rel|
        r = Relationship.new
        puts "Creating relationship for #{rel[0]}.#{rel[1]} to #{rel[2]}.#{rel[3]}"
        r.table_from = model.find_business_table('en_US', rel[0])
        raise "Can't have a nil business table" if r.table_from == nil
        r.field_from = model.find_business_table(rel[0]).find_business_column(rel[1])
        r.table_to = model.find_business_table(rel[2])
        r.field_to = model.find_business_table(rel[2]).find_business_column(rel[3])
        r.type = rel[4]
        model.add_relationship r
    end

    puts "Building Business Categories"
    root_bc = BusinessCategory.new
    root_bc.set_root_category true
    get_query_results("SELECT category_name, display_name FROM categories ORDER BY order_num", conn).each do |cat|
      bc = BusinessCategory.new(cat[0])
      puts "#{cat[0]}"
      bc.set_name('en_US', cat[1])
      get_query_results(category_columns(cat[0]), conn).each do |ccat|
        mbt = model.find_business_table(ccat[0])
        raise "Didn't find table #{ccat[0]}" if mbt.nil?
        mbc = mbt.find_business_column(ccat[1])
        if mbc.nil? 
          puts "Writing business columns for table #{ccat[0]}"
          mbt.get_business_columns.each do |a| puts a.get_name('en_US') end
          puts "Done writing business columns for table #{ccat[0]}"
          raise "Didn't find column #{ccat[0]}.#{ccat[1]}" if mbc.nil?
        end
        puts "  #{ccat[0]} #{ccat[1]}"
        puts "  - #{mbc.get_name('en_US')}"
        bc.add_business_column(mbc)
      end
      secure bc
      bc.set_root_category false
      root_bc.add_business_category(bc)
    end
    model.set_root_category(root_bc)
    setup_role_security model, meta, jurisdiction_hash(conn)
  end #db_connection

  meta.add_model(model)
  cwm = CWM.get_instance('test')
  CwmSchemaFactory.new.store_schema_meta(cwm, meta, nil)
  puts "Writing out new XMI file"
  File.open('my_metadata.xmi', 'w') do |io|
    io << cwm.getXMI
  end
end
