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

def require_jars(jars)
  jars.each {|jar| require jar}
end

Metafile = '/home/josh/devel/trisano/avr/bi/schema/metadata.xmi'
ServerURL = 'http://127.0.0.1:8080'

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

puts "Getting schema factory"
schema_factory = CwmSchemaFactory.new    
puts "Getting CWM -- whatever that is"
cwm = CWM.get_instance('__tmp_domain__')
puts "Importing metadata. This... takes a while."
cwm.importFromXMI Metafile
puts "Getting metadata object"
meta = schema_factory.getSchemaMeta(cwm)
puts "Fiddling with domains"
cwm.remove_domain
cwm = CWM.get_instance('TriSano')

puts "Getting security constraint map"
rbsm = meta.findModel('TriSano').rowLevelSecurity.getRoleBasedConstraintMap
existing_rules = []
rbsm.keySet.each {
    |mykey|
    existing_rules.push(mykey) if mykey !~ /admin/i
}

existing_rules.each {
    |rulename|
    rbsm.remove(rulename)
}

puts "Getting defined roles from Pentaho"
secserv = meta.securityReference.securityService
secserv.serviceURL = "#{ServerURL}/pentaho/ServiceAction?action=SecurityDetails&details=all"
pentaho_roles = secserv.getRoles

puts "Getting jurisdictions from the database"
dbinfo = nil
meta.databases.each { |db|
    if db.name =~ /TriSano/ then
        dbinfo = db
        break
    end
}

dbconn = eval("#{dbinfo.driver_class}").new
props = Java::JavaUtil::Properties.new
props.setProperty "user", dbinfo.username
props.setProperty "password", dbinfo.password

# TODO: Exception handling
conn = dbconn.connect dbinfo.getURL, props

juris_query = %{
    SELECT p.name
    FROM trisano.places_view p
    JOIN trisano.places_types_view pt
        ON (p.id = pt.place_id)
    JOIN trisano.codes_view c
        ON (c.id = pt.type_id)
    WHERE c.code_description = 'Jurisdiction'}
dbjurisdictions = conn.prepare_call(juris_query).execute_query
dbjuris = {}

while dbjurisdictions.next 
    juris = dbjurisdictions.getString(1)
    dbjuris[juris] = 1
    puts "Found jurisdiction #{juris}"
end

pentaho_roles.each { |rolename|
    puts "Pentaho role: #{rolename}"
    if dbjuris[rolename] == 1 then
        puts "Found role matching jurisdiction: #{rolename}"
        rbsm.put(SecurityOwner.new(1, rolename), "OR([MorbidityEvents.BC_DW_MORBIDITY_EVENTS_VIEW_INVESTIGATING_JURISDICTION]=\"#{rolename}\" ;  [MorbiditySecondaryJurisdictions.BC_DW_MORBIDITY_SECONDARY_JURISDICTIONS_VIEW_NAME] = \"#{rolename}\")")
    end
}

puts "Saving results to metadata.out"
CwmSchemaFactory.new.store_schema_meta(cwm, meta, nil)
File.open('metadata.out', 'w') { |io|
    io << cwm.getXMI
}
