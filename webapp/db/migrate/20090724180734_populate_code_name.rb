# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

class PopulateCodeName < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      code_names = YAML::load_file "#{RAILS_ROOT}/db/defaults/code_names.yml"

      CodeName.transaction do
        code_names.each do |code_name|
          c = CodeName.find_or_initialize_by_code_name(:code_name => code_name['code_name'], 
                                                       :description => code_name['description'],
                                                       :external => code_name['external'])
          c.attributes = code_name unless c.new_record?
          c.save!
        end
      end
    end
  end

  def self.down
  end
end
