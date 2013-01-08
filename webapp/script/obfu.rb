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

#Some helpers in the script
def get_random_number(words)
  wordlist1 = ["2","3","4","5","6","7","8","9"]
  wordlist2 = ["0","1","2","3","4","5","6","7","8","9"]
  result = wordlist1[rand(8)]
  (words - 1).times do
    result = result + wordlist2[rand(10)]
  end
  result
end

def get_random_words(words)
  wordlist = ["Lorem","ipsum","dolor","sit","amet","consectetuer","adipiscing","elit","Duis","sodales","dignissim","enim","Nunc","rhoncus","quam","ut","quam","Quisque","vitae","urna","Duis","nec","sapien","Proin","mollis","congue","mauris","Fusce","lobortis","tristique","elit","Phasellus","aliquam","dui","id","placerat","hendrerit","dolor","augue","posuere","tellus","at","ultricies","libero","leo","vel","leo","Nulla","purus","Ut","lacus","felis","tempus","at","egestas","nec","cursus","nec","magna","Ut","fringilla","aliquet","arcu","Vestibulum","ante","ipsum","primis","in","faucibus","orci","luctus","et","ultrices","posuere","cubilia","Curae","Etiam","vestibulum","urna","sit","amet","sem","Nunc","ac","ipsum","In","consectetuer","quam","nec","lectus","Maecenas","magna","Nulla","ut","mi","eu","elit","accumsan","gravida","Praesent","ornare","urna","a","lectus","dapibus","luctus","Integer","interdum","bibendum","neque","Nulla","id","dui","Aenean","tincidunt","dictum","tortor","Proin","sagittis","accumsan","nulla","Etiam","consectetuer","Etiam","eget","nibh","ut","sem","mollis","luctus","Etiam","mi","eros","blandit","in","suscipit","ut","vestibulum","et","velit","Fusce","laoreet","nulla","nec","neque","Nam","non","nulla","ut","justo","ullamcorper","egestas","In","porta","ipsum","nec","neque","Cras","non","metus","id","massa","ultrices","rhoncus","Donec","mattis","odio","sagittis","nunc","Vivamus","vehicula","justo","vitae","tincidunt","posuere","risus","pede","lacinia","dolor","quis","placerat","justo","arcu","ut","tortor","Aliquam","malesuada","lectus","id","condimentum","sollicitudin","arcu","mauris","adipiscing","turpis","a","sollicitudin","erat","metus","vel","magna","Proin","scelerisque","neque","id","urna","lobortis","vulputate","In","porta","pulvinar","urna","Cras","id","nulla","In","dapibus","vestibulum","pede","In","ut","velit","Aliquam","in","turpis","vitae","nunc","hendrerit","ullamcorper","Aliquam","rutrum","erat","sit","amet","velit","Nullam","pharetra","neque","id","pede","Phasellus","suscipit","ornare","mi","Ut","malesuada","consequat","ipsum","Suspendisse","suscipit","aliquam","nisl","Suspendisse","iaculis","magna","eu","ligula","Sed","porttitor","eros","id","euismod","auctor","dolor","lectus","convallis","justo","ut","elementum","magna","magna","congue","nulla","Pellentesque","eget","ipsum","Pellentesque","tempus","leo","id","magna","Cras","mi","dui","pellentesque","in","pellentesque","nec","blandit","nec","odio","Pellentesque","eget","risus","In","venenatis","metus","id","magna","Etiam","blandit","Integer","a","massa","vitae","lacus","dignissim","auctor","Mauris","libero","metus","aliquet","in","rhoncus","sed","volutpat","quis","libero","Nam","urna"]
  result = wordlist[rand(319)]
  (words - 1).times do
    result = result + wordlist[rand(319)]
  end
  result
end

def get_random_email
  get_random_words(1) + '@' + get_random_words(1) + '.localhost'
end

def get_random_date(keep_year, cur_value)
  # Creates random dates of this format: "1971-12-12"
  keep_year ? cur_value[0..4] + "%02d" % (rand(11)+1).to_s + "-" + "%02d" % (rand(27)+1).to_s : (rand(100)+1907).to_s + "-" + "%02d" % (rand(11)+1).to_s + "-" + "%02d" % (rand(27)+1).to_s
end

def set_value(line, field)

  start_loc = line.index("\t")
  rep = field[:field_loc] - 2

  #puts "rep: " + rep.to_s

  rep.times do
    start_loc = line.index("\t", start_loc + 1)
  end

  #puts "start_loc: " + start_loc.to_s
  stop_loc = line.index("\t", start_loc + 1)
  stop_loc.nil? ? stop_loc = line.size - 1 : stop_loc = stop_loc
  #puts "stop_loc: " + stop_loc.to_s
  cur_value = line[start_loc + 1..stop_loc - 1]
  #puts "cur_value: " + cur_value
  if cur_value == '\N' or cur_value == ""
    value = cur_value
  else
    case field[:type]
    when 'value'
      value = field[:value]
    when 'num'
      value = get_random_number(field[:digits])
    when 'email'
      value = get_random_email
    when 'text'
      value = get_random_words(field[:word_count])
    when 'date'
      #value = get_random_date(field[:keep_year], cur_value)
      value = cur_value #Disabling date obfu temporarily
      #value = "2009-02-01"
    when 'nil'
      value = ""
    end
  end
  #puts "value: " + value
  line[0..start_loc] + value + line[stop_loc..line.size]

end

#set up the object for tracking what to obfu
def get_obfu_config
  [
    {#COPY telephones (id, location_id, country_code, area_code, phone_number, extension, created_at, updated_at, email_address, entity_id, entity_location_type_id) FROM stdin;
      :table_name => 'telephones', :fields => [
        {:field_loc => 4, :type => 'value', :value => '555'},  # Area code
        {:field_loc => 5, :type => 'num', :digits => 7},       # Phone number
        {:field_loc => 6, :type => 'num', :digits => 3},       # Extension
        {:field_loc => 9, :type => 'email'} # email
      ]
    },
    {#COPY notes (id, note, struckthrough, user_id, created_at, updated_at, event_id, note_type)
      :table_name => 'notes', :fields => [
        {:field_loc => 2, :type => 'text', :word_count => 10}  # note
      ]
    },
    {#COPY people (id, entity_id, race_id, birth_gender_id, current_gender_id, ethnicity_id, primary_language_id, first_name, middle_name, last_name, birth_date, date_of_death, food_handler_id, healthcare_worker_id, group_living_id, day_care_association_id, age_type_id, risk_factors, risk_factors_notes, approximate_age_no_birthday, person_type, created_at, updated_at) FROM stdin;
      :table_name => 'people', :fields => [
        {:field_loc => 8, :type => 'text', :word_count => 1},  # first_name
        {:field_loc => 9, :type => 'text', :word_count => 1},  # middle_name
        {:field_loc => 10, :type => 'text', :word_count => 1},  # last_name
        {:field_loc => 11, :type => 'date', :keep_year => true}, # birth_date
        {:field_loc => 12, :type => 'date', :keep_year => true}, # date_of_death
      ]
    },
    {#COPY addresses (id, location_id, county_id, state_id, street_number, street_name, unit_number, postal_code, created_at, updated_at, city, entity_id, entity_location_type_id, event_id, longitude, latitude) FROM stdin;
      :table_name => 'addresses', :fields => [
        {:field_loc => 5, :type => 'num', :digits => 5},  # street_number
        {:field_loc => 6, :type => 'text', :word_count => 2},  # street_name,
        {:field_loc => 7, :type => 'num', :digits => 3},  # unit_number,
        {:field_loc => 8, :type => 'num', :digits => 5}, # postal_code
        {:field_loc => 11, :type => 'text', :word_count => 1},  # street_name,
      ]
    },
    {#COPY event_queues (id, queue_name, jurisdiction_id) FROM stdin;
      :table_name => 'event_queues', :fields => [
        {:field_loc => 2, :type => 'text', :word_count => 3}  # queue_name,
      ]
    },
#    {#COPY organizations (id, entity_id, organization_type_id, organization_status_id, organization_name, duration_start_date, duration_end_date, created_at, updated_at) FROM stdin;
#      :table_name => 'organizations', :fields => [
#        {:field_loc => 5, :type => 'text', :word_count => 3}  # organization_name,
#      ]
#    },
    {#COPY hospitals_participations (id, participation_id, hospital_record_number, admission_date, discharge_date, created_at, updated_at, medical_record_number)
      :table_name => 'hospitals_participations', :fields => [
        {:field_loc => 4, :type => 'date', :keep_year => true}, # admission_date
        {:field_loc => 5, :type => 'date', :keep_year => true}, # discharge_date
        {:field_loc => 8, :type => 'num', :digits => 20}, # medical_record_number
      ]
    },
    {#COPY disease_events (id, event_id, disease_id, hospitalized_id, died_id, disease_onset_date, date_diagnosed, created_at, updated_at)
      :table_name => 'disease_events', :fields => [
        #{:field_loc => 6, :type => 'date', :keep_year => true}, # disease_onset_date
        {:field_loc => 7, :type => 'date', :keep_year => true} # date_diagnosed
      ]
    },
    {#COPY participations_treatments (id, participation_id, treatment_id, treatment_given_yn_id, treatment_date, created_at, updated_at, stop_treatment_date, "position") FROM stdin;
      :table_name => 'participations_treatments', :fields => [
        {:field_loc => 5, :type => 'date', :keep_year => true}, # treatment_date
        {:field_loc => 8, :type => 'date', :keep_year => true}  # stop_treatment_date
      ]
    },
    {#COPY lab_results (id, specimen_source_id, collection_date, lab_test_date, specimen_sent_to_state_id, created_at, updated_at, participation_id, reference_range, staged_message_id, loinc_code, test_type_id, test_result_id, result_value, units, test_status_id, comment, organism_id, "position", accession_no) FROM stdin;
      :table_name => 'lab_results', :fields => [
        {:field_loc => 3, :type => 'date', :keep_year => true}, # collection_date
        {:field_loc => 4, :type => 'date', :keep_year => true} # lab_test_date
      ]
    },
    {#Include this table so we can skip its rows.
      :table_name => 'attachments', :drop_me => true, :fields => [
        {:field_loc => 2, :type => 'num', :digits => 10} #not really used, just need to have something in here
      ]
    },
    {#Include this table so we can skip its rows.
      :table_name => 'db_files', :drop_me => true, :fields => [
        {:field_loc => 2, :type => 'num', :digits => 10} #not really used, just need to have something in here
      ]
    }
  ]
end

#read in the dump file
#TODO - make this user selected (in and out)
ARGV[0].nil? ? return : file_in = ARGV[0]
ARGV[1].nil? ? return : file_out = ARGV[1]
file_in = File.new(file_in, "r")
file_out = File.new(file_out, "w")

active_table = nil

tables = get_obfu_config
counter = 0

while (line = file_in.gets)
  tables.each do |table|
    if active_table == table
      if line.index("\\.").nil?
        table[:fields].each do |field|
          if active_table[:drop_me]
            line = nil
          else
            line = set_value(line, field)
          end
          counter = counter + 1
        end        
      else
        puts "#{table[:drop_me] ? "Removed" : "Updated"} #{counter.to_s} rows in table: #{table[:table_name]}."
        active_table = nil
        counter = 0
      end
    end
    if line != nil && line.index("COPY " + table[:table_name] + " ") != nil
      active_table = table 
    end
  end
  file_out.puts(line) unless line == nil

end

file_in.close
file_out.close

