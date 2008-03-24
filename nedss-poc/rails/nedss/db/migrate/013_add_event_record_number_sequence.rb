class AddEventRecordNumberSequence < ActiveRecord::Migration
  
  def self.up
    execute "CREATE SEQUENCE events_record_number_seq INCREMENT 1 START 2008000001 MINVALUE 2008500001 MAXVALUE 2008999999 CACHE 1;"
  end
  
  def self.down
   execute "DROP SEQUENCE events_record_number_seq;" 
  end
  
end
