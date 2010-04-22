class CoreFieldTranslations < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    transaction do
      create_table(:core_field_translations) do |t|
        t.integer(:core_field_id, :null => false)
        t.string(:locale, :null => false)
        t.text(:help_text)
        t.timestamps
      end
      add_foreign_key(:core_field_translations, :core_field_id, :core_fields)
      add_index(:core_field_translations, [:core_field_id, :locale], :unique => true)
      execute(<<-SQL)
        INSERT INTO core_field_translations (id, core_field_id, locale, help_text, created_at, updated_at)
          SELECT nextval('core_field_translations_id_seq'), id, 'en', help_text, now(), now()
          FROM core_fields;
      SQL
      remove_column(:core_fields, :help_text)
    end
  end

  def self.down
    transaction do
      drop_table(:core_field_translations)
      add_column(:core_fields, :help_text, :text)
    end
  end
end
