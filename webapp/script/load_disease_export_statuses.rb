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

puts 'Loading CDC disease export statuses'

@case_statuses = {
  :confirmed => ExternalCode.find_by_code_name_and_the_code('case', 'C'),
  :probable  => ExternalCode.find_by_code_name_and_the_code('case', 'P'),
  :suspect   => ExternalCode.find_by_code_name_and_the_code('case', 'S'),
  :unknown   => ExternalCode.find_by_code_name_and_the_code('case', 'UNK')
}
@diseases_statuses = YAML.load_file File.join(RAILS_ROOT, 'db', 'defaults', 'disease_cdc_export_statuses.yml')


def cdc_diseases
  Disease.find(:all, :conditions => ['cdc_code is not null'])
end

def statuses_for(disease)
  return [] unless @diseases_statuses[disease.disease_name]  
  @diseases_statuses[disease.disease_name].collect{|v| v[0].to_sym if v[1]}.compact.collect do |status|    
    @case_statuses[status]
  end
end

Disease.transaction do
  cdc_diseases.each do |disease|
    statuses_for(disease).each {|status| disease.cdc_disease_export_statuses << status}
    disease.save!
  end
end
