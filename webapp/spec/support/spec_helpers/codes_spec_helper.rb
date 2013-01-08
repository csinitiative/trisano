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
module CodesSpecHelper

  def given_external_codes(code_name, the_codes, options={})
    given_code_name(code_name, true)
    the_codes.map do |the_code|
      code = external_code!(code_name, the_code, options)
      yield(code) if block_given?
      code
    end
  end

  def given_codes(code_name, the_codes)
    given_code_name(code_name, false)
    the_codes.each do |the_code|
      code = code!(code_name, the_code)
      yield(code) if block_given?
    end
  end

  def given_disease_specific_external_codes(disease_name, code_name, the_codes)
    given_code_name(code_name)
    disease = disease!(disease_name)
    given_external_codes(code_name, the_codes, :disease_specific => true) do |code|
      disease.disease_specific_selections.create(:external_code => code, :rendered => true)
    end
    disease
  end

  def given_code_name(code_name, external=true)
    instance = CodeName.find_by_code_name(code_name)
    if instance
      raise "Code name already specified as #{external ? 'internal' : 'external'}" if external != instance.external
    else
      instance = Factory.create(:code_name, :code_name => code_name, :external => external)
    end
  end

  def given_task_category_codes_loaded
    task_category_attributes.map do |attributes|
      ExternalCode.find_or_create_by_the_code_and_code_name(attributes)
    end
  end

  def given_contact_disposition_type_codes_loaded
    contact_disposition_type_attributes.map do |attributes|
      ExternalCode.find_or_create_by_the_code_and_code_name(attributes)
    end
  end

  def given_contact_type_codes_loaded
    contact_type_attributes.map do |attributes|
      ExternalCode.find_or_create_by_the_code_and_code_name(attributes)
    end
  end

  def given_race_codes_loaded
    race_type_attributes.map do |attributes|
      ExternalCode.find_or_create_by_the_code_and_code_name(attributes)
    end
  end

  def task_category_attributes
    default_code_attributes.select { |attributes| attributes['code_name'] == 'task_category' }
  end

  def contact_disposition_type_attributes
    default_code_attributes.select { |attributes| attributes['code_name'] == 'contactdispositiontype' }
  end

  def contact_type_attributes
    default_code_attributes.select { |attributes| attributes['code_name'] == 'contact_type' }
  end

  def race_type_attributes
    default_code_attributes.select { |attributes| attributes['code_name'] == 'race' }
  end

  def default_code_attributes
    codes = YAML::load_file(File.dirname(__FILE__) + '/../../../vendor/trisano/trisano_en/config/misc/en_codes.yml')
    contact_types = YAML::load_file(File.dirname(__FILE__) + '/../../../vendor/trisano/trisano_en/config/misc/en_contact_types.yml')
    codes + contact_types
  end

  def external_code!(code_name, the_code, options={})
    code = ExternalCode.find_by_code_name_and_the_code(code_name, the_code)
    unless code
      code = Factory.create(:external_code, :code_name => code_name, :the_code => the_code)
    end
    code.update_attributes!(options)
    code
  end

  def code!(code_name, the_code)
    code = Code.find_by_code_name_and_the_code(code_name, the_code)
    unless code
      code = Factory.create(:code, :code_name => code_name, :the_code => the_code)
    end
    code
  end
end
