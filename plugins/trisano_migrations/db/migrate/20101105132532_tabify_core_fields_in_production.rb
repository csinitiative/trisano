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

class TabifyCoreFieldsInProduction < ActiveRecord::Migration
  def self.up
    if ENV['UPGRADE']
      CoreField.reset_column_information
      unless acting_as_nested_set?(CoreField)
        CoreField.instance_eval { acts_as_nested_set :scope => :tree_id }
      end
      say "Updating core fields for tabs and sections"
      transaction do
        all_core_field_defaults.each do |config|
          add_child parent_core_field(config), core_field(config)
        end
      end
    end
  end

  def self.down
  end

  private

  def self.acting_as_nested_set?(clazz)
    clazz.respond_to? :roots
  end

  def self.all_core_field_defaults
    load_configs(existing_sources(core_field_sources))
  end

  def self.load_configs(file_paths)
    return nil if file_paths.nil?
    say "Using the following core field sources:"
    file_paths.map do |path|
      say path
      YAML::load_file(path)
    end.flatten
  end

  def self.existing_sources(sources)
    sources.select do |source|
      File.exists?(source)
    end
  end

  def self.core_field_sources
    %w(db/defaults/core_fields.yml
       vendor/trisano/trisano_perinatal_hep_b/db/defaults/core_fields.yml
      ).map { |path| File.join(RAILS_ROOT, path) }
  end

  def self.tree_id(field=nil)
    field.try(:tree_id) || CoreField.next_tree_id
  end

  def self.add_child(parent, child)
    return if parent.nil?
    insert_location = insert_location(parent)
    execute(<<-SQL)
      UPDATE core_fields SET rgt = rgt + 2
       WHERE rgt > #{insert_location} AND tree_id = #{parent.tree_id};

      UPDATE core_fields SET lft = lft + 2
       WHERE lft > #{insert_location} AND tree_id = #{parent.tree_id};

      UPDATE core_fields
         SET lft = #{insert_location + 1},
             rgt = #{insert_location + 2},
             parent_id = #{parent.id},
             tree_id = #{parent.tree_id}
       WHERE id = #{child.id}
    SQL
  end

  def self.insert_location(parent)
    parent.reload(:select => 'lft, rgt')
    if parent_empty?(parent)
      parent.lft
    else
      parent.rgt - 1
    end
  end

  def self.parent_empty?(field)
    field.lft + 1 == field.rgt
  end

  def self.parent_core_field(config)
    parent_key = config['parent_key']
    if parent_key
      parent_cache[parent_key] ||= CoreField.find_by_key(parent_key)
    end
  end

  def self.core_field(config)
    if  CoreField.exists?(:key => config['key'])
      update_core_field(core_field_attributes(config))
    else
      create_core_field(core_field_attributes(config))
    end
    CoreField.find_by_key(config['key'])
  end

  def self.core_field_attributes(config)
    insert_tree_id(insert_code_id(config)).reject do |key, value|
      value.nil? || %w(parent_key code_name).include?(key.to_s)
    end
  end

  def self.insert_tree_id(attributes)
    return attributes if attributes.has_key?('parent_key')
    attributes.merge('tree_id' => CoreField.next_tree_id)
  end

  def self.insert_code_id(attributes)
    code_name = attributes['code_name']
    attributes.merge('code_name_id' => code_name_id(attributes))
  end

  def self.create_core_field(attributes)
    CoreField.create!(attributes)
  end

  def self.update_core_field(attributes)
    CoreField.update_all(<<-SQL, ['key = ?', attributes['key']])
      required_for_event = #{attributes['required_for_event'] || false},
      required_for_section = #{attributes['required_for_section'] || false}
    SQL
  end

  def self.code_name_id(config)
    code_name = config['code_name']
    code_name_id_cache[code_name] ||= lookup_code_name_id(code_name)
  end

  def self.lookup_code_name_id(code_name)
    return if code_name.blank?
    CodeName.first(:conditions => {:code_name => code_name}, :select => 'id').id
  end

  def self.code_name_id_cache
    @code_name_id_cache ||= {}
  end

  def self.parent_cache
    @parent_cache ||= {}
  end
end
