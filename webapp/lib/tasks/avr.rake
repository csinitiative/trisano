# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

require 'rubygems'
require 'pg'
require 'erb'

namespace :avr do
    def db_config
        @db_config = YAML::load(ERB.new(File.read('./config/database.yml')).result) if @config.nil?
        @db_config
    end

    def get_warehouse_connection
        if db_config['development'].nil?
          raise "Development environment is not defined."
        end
        dbhost   = db_config[RAILS_ENV]['warehouse_host']
        dbport   = db_config[RAILS_ENV]['warehouse_port']
        dbname   = db_config[RAILS_ENV]['warehouse_database']
        dbuser   = db_config[RAILS_ENV]['warehouse_username']
        dbpass   = db_config[RAILS_ENV]['warehouse_password']

        conn = PG.connect( :dbname => dbname, :host => dbhost, :port => dbport, :user => dbuser, :password => dbpass )
        yield conn
    end
    
    desc 'test getting a connection'
    task :get_connection => :rails_env do
        get_warehouse_connection do
            puts "Yay!"
        end
    end
end

if RUBY_PLATFORM =~ /java/
  require 'java'
  require 'fileutils'
  require 'yaml'
  require 'csv'
  require 'jdbc/postgres'

  namespace :trisano do
    namespace :avr do

      def create_db_connection(driver_class)
          eval("#{driver_class}").new
      end

      def db_connection
        db_config = YAML::load(ERB.new(File.read('./config/database.yml')).result)
        # XXX Should "development" be hardcoded here?
        if db_config['development'].nil?
          raise "Development environment is not defined."
        end
        database_host   = db_config['development']['warehouse_host']
        database_port   = db_config['development']['warehouse_port']
        database_name   = db_config['development']['warehouse_database']
        database_user   = db_config['development']['warehouse_username']
        database_pass   = db_config['development']['warehouse_password']
        database_driver = db_config['development']['warehouse_driver']

        if database_host.nil? then
            puts "Your warehouse database host isn't set - are the warehouse options configured in database.yml?"
        end
        props = Java::JavaUtil::Properties.new
        props.setProperty "user", database_user
        props.setProperty "password", database_pass
        database_url = "jdbc:postgresql://#{database_host}:#{database_port}/#{database_name}"
        begin
          conn = create_db_connection(database_driver).connect database_url, props
          conn.create_statement.execute_update("SET search_path = 'trisano'");
          yield conn
        rescue
          e = $!
          puts "Some exception occurred connecting to the database: #{e}"
          raise e
        ensure
          conn.close if conn
        end
      end

      def get_query_results(query_string, conn)
          return nil if query_string.nil?
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

      def run_statement(query_string, conn)
        conn.create_statement.execute_update query_string
      end

      def run_statements(statements, conn)
        statements.each do |s|
            run_statement s, conn
        end
      end

      def csv_file_to_values(filename)
        contents = CSV::parse(File.read(filename))
        statement = ((contents.reject { |a| a[0] =~ /^\s*#/ } ).map { |x| '(' + x.join(', ') + ")"} ).join(",\n")
        return statement
      end

      def recreate_table(tablename, yml_file, yml_key, csv_file, insert_stmt)
        db_connection do |conn|
          begin
            create_stmts = YAML::load(ERB.new(File.read(yml_file)).result)
            run_statements create_stmts[yml_key], conn
            insert_stmt += csv_file_to_values csv_file
            run_statement insert_stmt, conn
          rescue
            e = $!
            puts "Some exception occurred recreating #{tablename}: #{e}"
            raise e
          end
        end
      end

      desc "Set up trisano.core_tables"
      task :recreate_core_tables do
        name = 'trisano.core_tables'
        yml_file = './config/avr/build_metadata.yml'
        yml_key = 'core_tables'
        csv_file = './config/avr/core_tables_contents.csv'
        insert = %{
            INSERT INTO core_tables
                (make_category, table_name, table_description,
                 target_table, order_num, formbuilder_prefix)
            VALUES }
        recreate_table name, yml_file, yml_key, csv_file, insert
      end

      desc "Set up trisano.core_columns"
      task :recreate_core_columns do
        name = 'trisano.core_columns'
        yml_file = './config/avr/build_metadata.yml'
        yml_key = 'core_columns'
        csv_file = './config/avr/core_columns_contents.csv'
        insert = %{
            INSERT INTO trisano.core_columns
                (target_table, target_column, column_name,
                 column_description, make_category_column)
            VALUES }
        recreate_table name, yml_file, yml_key, csv_file, insert
      end

      desc "Set up trisano.core_relationships"
      task :recreate_core_relationships do
        name = 'trisano.core_relationships'
        yml_file = './config/avr/build_metadata.yml'
        yml_key = 'core_relationships'
        csv_file = './config/avr/core_relationships_contents.csv'
        insert = %{
            INSERT INTO trisano.core_relationships
                (from_table, from_column, to_table, to_column, relation_type, join_order)
            VALUES }
        recreate_table name, yml_file, yml_key, csv_file, insert
      end

      desc "Set up trisano.core_view_mods"
      task :recreate_core_view_mods do
        db_connection do |conn|
          begin
            run_statements ['TRUNCATE TABLE trisano.view_mods'], conn
            insert_stmt = 'INSERT INTO trisano.view_mods (table_name, addition) VALUES'
            insert_stmt += csv_file_to_values './config/avr/core_view_mods.csv'
            run_statement insert_stmt, conn
          rescue
            e = $!
            puts "Some exception occurred recreating core view_mods entries: #{e}"
            raise e
          end
        end
      end

      desc "Set up core table AVR schema metadata"
      task :metadata_schema_core => [:recreate_core_tables, :recreate_core_columns, :recreate_core_relationships, :recreate_core_view_mods]

      task :metadata_schema_plugins => [:metadata_schema_core] do
        db_connection do |conn|
          FileList.new('vendor/trisano/*/avr/build_metadata_schema.rb').each do |avr_file|
            require avr_file
            puts "Running metadata_schema for plugin from #{avr_file}"
            TriSano_metadata_plugin.new(conn, lambda { |x, y| get_query_results(x, y) })
          end
        end
      end

      desc "Set up the AVR metadata schema tables"
      task :metadata_schema => [:metadata_schema_core, :metadata_schema_plugins]
    end
  end
end
