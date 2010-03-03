class ChangeImportCodesToExternal < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      code_name = CodeName.find_by_code_name('imported')
      CodeName.transaction do
          code_name.external = true
          code_name.save!
      end
    end
  end

  def self.down
    if RAILS_ENV == 'production'
      code_name = CodeName.find_by_code_name('imported')
      CodeName.transaction do
          code_name.external = false
          code_name.save!
      end
    end
  end
end
