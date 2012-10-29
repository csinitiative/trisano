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

require 'csv'

module SearchHelper
  extensible_helper

  # Debt: This is here because it's a special case of finding a record
  # for search csv and it makes mocking the view logic easier. Also, I
  # toyed with the idea of adding a method to the event model, but the
  # possibility of an event.event call was just too awful.
  def find_event(record)
    Event.find(record.event_id)
  end

  # Not very Ruby, but...
  def array_of_strs_to_ints(str_array)
    str_array.collect { |str| str.to_i } unless str_array.nil?
  end

  def gender_select_search_tag(genders, name = :gender)
    returning "" do |result|
      result << label_tag(name, t(name))
      result << select_tag(name, gender_select_search_options(genders, name))
    end
  end

  def gender_select_search_options(genders, param_name = :gender)
    container = genders.map { |g| [g.code_description, g.id.to_s] }
    container.unshift [nil,nil]
    options_for_select container, params[param_name]
  end

  def search_result_full_name(record)
    returning "" do |full_name|
      full_name << h(record['last_name'])
      full_name << ", #{h(record['first_name'])}" unless record['first_name'].blank?
      full_name << " #{h(record['middle_name'])}" if record['middle_name']
    end.strip
  end

  def search_result_event_path(event)
    event_path(event)
  end

  def search_result_link_id(event)
    type = altered_paths_map[event.type]
    "show-#{type}-link-#{event.id}"
  end

  def link_to_search_result_event(text, event)
    link_to(text,
            search_result_event_path(event),
            :id => search_result_link_id(event),
            :class => 'show_link')
  end

  def search_result_class(event)
    event['deleted_at'].nil? ? 'search-active' : 'search-inactive'
  end

  def name_criteria_fields(params)
    returning [] do |fields|

      fields << div_tag(:class => :horiz) do
        returning "" do |html|
          html << label_tag(:name, t(:full_text_name))
          html << text_field_tag(:name, params[:name], :size => 30, :class => 'search')
          html << "<br/>"
          html << "<small>#{t(:uses_soundex)}</small>"
        end
      end

      fields << div_tag(:class => :horiz) do
       returning "" do |html|
         html << label_tag(:sw_first_name, t(:starts_with_first_name))
         html << text_field_tag(:sw_first_name, params[:sw_first_name], :class => 'search')
         html << "<br/>"
         html << "<small>#{t(:ignore_fts)}</small>"
       end
     end

      fields << div_tag(:class => :horiz) do
        returning "" do |html|
          html << label_tag(:sw_last_name, t(:starts_with_last_name))
          html << text_field_tag(:sw_last_name, params[:sw_last_name], :class => 'search')
        end
      end
      fields << div_tag(:class => :vert) do
        returning "" do |html|
          html << div_tag(:class => :horiz) do
            returning "" do |input|
              input << label_tag(:record_number, t(:record_number))
              input << text_field_tag(:record_number, params[:record_number], :size => 30, :class => "search")
            end
          end

          html << div_tag(:class => :horiz) do
            returning "" do |input|
              input << label_tag(:birth_date, t(:date_or_year_of_birth))
              input << text_field_tag(:birth_date, params[:birth_date], :class => "search")
            end
          end
        end
      end
    end
  end

  def demographic_criteria_fields(params, counties, genders)
    returning [] do |fields|

      fields << div_tag(:class => :horiz) do
        returning "" do |html|
          html << label_tag(:city, t(:city))
          html << model_auto_completer('city', params[:city], "", "",
                                       { :allow_free_text => true },
                                       { :size => 25 },
                                       { :skip_style => false })
        end
      end

      fields << div_tag(:class => :horiz) do
        returning "" do |html|
          html << label_tag(:county, t(:county))
          html << code_description_select_tag(:county,
                                              counties,
                                              params[:county].to_i,
                                              :include_blank => true)
        end
      end

      fields << div_tag(:class => :horiz) do
        returning "" do |html|
          html << label_tag(:gender, t(:gender))
          html << code_description_select_tag(:gender,
                                              genders,
                                              params[:gender].to_i,
                                              :include_blank => true)
        end
      end
    end
  end

  def clinical_criteria_fields(params, diseases)
    returning [] do |fields|
      fields << div_tag(:class => :horiz) do
        html = label_tag(:diseases, t(:diseases))
        html << scroll_panel do
          diseases.map do |d|
            check_box = "<label>"
            check_box << check_box_tag("diseases[]", d.id,
                                       (params[:diseases] || []).include?(d.id.to_s),
                                       :id => d.disease_name.tr(" ", "_"))
            check_box << h(d.disease_name)
            check_box << "</label>"
            check_box
          end.join("\n")
        end
        html
      end

      fields << div_tag(:class => :horiz) do
        html =  label_tag(:pregnant_id, t(:pregnant))
        html << yesno_select(:pregnant_id, params['pregnant_id'].to_i)
        html
      end
    end
  end

  def event_criteria_fields(params, workflow_states, event_types, jurisdictions, investigators)
    [div_tag(:class => :horiz) do
       html =  label_tag(:workflow_state, t(:event_status))
       html << workflow_states_select_tag(workflow_states, params[:workflow_state])
     end,
     div_tag(:class => :horiz) do
       html =  label_tag(:event_type, t(:event_type))
       options = options_for_select([[nil, nil]] + event_types, params[:event_type])
       html << select_tag(:event_type, options)
     end,
     div_tag(:class => :horiz) do
       html =  label_tag(:sent_to_cdc, t(:sent_to_cdc))
       options = options_for_select([[nil, nil], [t(:yes_true), 'true'], [t(:no_false), 'false']], params[:sent_to_cdc])
       html << select_tag(:sent_to_cdc, options)
     end,
     div_tag(:class => :vert) do
       html =  label_tag(:entered_on_start, t(:entered_on_date_range))
       html << text_field_tag(:entered_on_start, params[:entered_on_start], :size => 10)
       html << "&nbsp;-&nbsp;"
       html << text_field_tag(:entered_on_end, params[:entered_on_end], :size => 10)
     end,
     div_tag(:class => :vert) do
       html =  label_tag(:jurisdiction_ids, t(:jurisdiction_of_investigation))
       options = options_from_collection_for_select(jurisdictions,
                                                    :entity_id, :short_name,
                                                    params[:jurisdiction_ids].try(:to_ints))
       html << select_tag(:jurisdiction_ids, options, :multiple => true, :size => 7)
     end,
     div_tag(:class => :horiz) do
       html = label_tag(:state_case_status_ids, t(:state_case_status))
       html << case_status_select(:state_case_status_ids,
                                  params[:state_case_status_ids].try(:to_ints),
                                  false, true)
     end,
     div_tag(:class => :horiz) do
       html = label_tag(:lhd_case_status_ids, t(:lhd_case_status))
       html << case_status_select(:lhd_case_status_ids,
                                  params[:lhd_case_status_ids].try(:to_ints),
                                  false, true)
     end,
     div_tag(:class => :horiz) do
       html = label_tag(:investigator_ids, t(:investigated_by))
       html << investigators_select(:investigator_ids, investigators,
                                    params[:investigator_ids].try(:to_ints))
     end]
  end

  def epi_criteria_fields(params)
    [div_tag(:class => :horiz) do
       html =  label_tag(:other_data_1, t(:other_data_1))
       html << text_field_tag(:other_data_1, params[:other_data_1], :size => 15)
     end,
     div_tag(:class => :horiz) do
       html =  label_tag(:other_data_2, t(:other_data_2))
       html << text_field_tag(:other_data_2, params[:other_data_2], :size => 15)
     end,
     div_tag(:class => :horiz) do
       html =  label_tag(:first_reported_PH_date_start, t(:first_reported_date_range))
       html << text_field_tag(:first_reported_PH_date_start,
                              params[:first_reported_PH_date_start],
                              :size => 10)
       html << "&nbsp;-&nbsp;"
       html << text_field_tag(:first_reported_PH_date_end,
                              params[:first_reported_PH_date_end],
                              :size => 10)
     end]
  end

  def workflow_states_select_tag(workflow_states, selected=nil)
    list =  [[nil, nil]]
    list += workflow_states.map { |s| [s.description, s.workflow_state.to_s] }
    select_tag(:workflow_state, options_for_select(list, selected))
  end

end
