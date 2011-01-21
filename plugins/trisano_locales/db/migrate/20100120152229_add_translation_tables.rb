class AddTranslationTables < ActiveRecord::Migration
  def self.up
    transaction do
      create_table :code_translations do |t|
        t.integer :code_id, :nil => false
        t.string  :locale, :nil => false
        t.string  :code_description, :limit => 100
        t.timestamps
      end
      add_index :code_translations, [:code_id, :locale], :unique => true

      create_table :external_code_translations do |t|
        t.integer :external_code_id, :nil => false
        t.string  :locale, :nil => false
        t.string  :code_description, :limit => 100
        t.timestamps
      end
      add_index :external_code_translations, [:external_code_id, :locale], :unique => true

      create_table :csv_field_translations do |t|
        t.integer :csv_field_id, :nil => false
        t.string  :locale, :nil => false
        t.string  :long_name
        t.string  :short_name
        t.timestamps
      end
      add_index :csv_field_translations, [:csv_field_id, :locale], :unique => true

      if ENV['UPGRADE']
        execute(<<-SQL)
          INSERT INTO code_translations (id, code_id, locale, code_description, created_at, updated_at)
            SELECT nextval('code_translations_id_seq'), id, 'en', code_description, now(), now()
            FROM codes;
        SQL

        execute(<<-SQL)
          INSERT INTO external_code_translations (id, external_code_id, locale, code_description, created_at, updated_at)
            SELECT nextval('external_code_translations_id_seq'), id, 'en', code_description, now(), now()
            FROM external_codes;
        SQL

        execute(<<-SQL)
          INSERT INTO csv_field_translations (id, csv_field_id, locale, long_name, short_name, created_at, updated_at)
            SELECT nextval('csv_field_translations_id_seq'), id, 'en', long_name, short_name, now(), now()
            FROM csv_fields;
        SQL
      end

    end
  end

  def self.down
    transaction do
      drop_table :code_translations
      drop_table :external_code_translations
      drop_table :csv_field_translations
    end
  end

end
