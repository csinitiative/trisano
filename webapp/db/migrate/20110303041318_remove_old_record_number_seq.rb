# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

class RemoveOldRecordNumberSeq < ActiveRecord::Migration
  def self.up
    transaction do
      execute("DROP SEQUENCE IF EXISTS events_record_number_seq")

      unless new_seq_exists?
        execute(<<-SQL)
          CREATE SEQUENCE events_caseid_seq
            START WITH 1 INCREMENT BY 1
            MINVALUE 1 MAXVALUE 999999
            CACHE 1 CYCLE;
        SQL
      end

      execute(<<-SQL)
        CREATE OR REPLACE FUNCTION set_events_record_number() RETURNS trigger AS $$
          BEGIN
            new.record_number := date_part('year', 'now'::date) || lpad(nextval('events_caseid_seq')::text, 6, '0');
            return new;
          END;
        $$ LANGUAGE plpgsql;
      SQL

      execute(<<-SQL)
        DROP TRIGGER IF EXISTS set_events_record_number ON events;

        CREATE TRIGGER set_events_record_number BEFORE INSERT ON events
          FOR EACH ROW EXECUTE PROCEDURE set_events_record_number();
      SQL
    end
  end

  def self.down
  end

  def self.new_seq_exists?
    rs = execute("SELECT * FROM pg_class WHERE relname='events_caseid_seq'")
    rs and rs.num_tuples > 0
  end
end
