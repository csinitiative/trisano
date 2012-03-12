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

class SearchController < ApplicationController
  include Blankable

  helper_method :max_search_results

  def index
  end

  def cmrs
    unless User.current_user.is_entitled_to?(:view_event)
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => t("no_event_view_privs") }, :status => 403 and return
    end

    flash[:error] = ""
    error_details = []

    @jurisdictions = User.current_user.jurisdictions_for_privilege(:view_event)

    @first_name = ""
    @middle_name = ""
    @last_name = ""

    @event_types = [[I18n.t(:event_search_type_morb), "MorbidityEvent"],
                    [I18n.t(:event_search_type_contact), "ContactEvent"]]

    @diseases = Disease.sensitive(User.current_user, nil).all(:order => "disease_name")

    @genders = ExternalCode.active.find(:all, :select => "id, code_description", :conditions => "code_name = 'gender'")
    @genders << Struct.new(:id, :code_description).new('Unspecified', t(:unspecified))

    @workflow_states = MorbidityEvent.get_states_and_descriptions

    @counties = ExternalCode.active.find(:all, :select => "id, code_description", :conditions => "code_name = 'county'")

    @investigators = User.investigators

    begin
      if not params.values_blank?

        if !params[:birth_date].blank?
          begin
            if (params[:birth_date].length == 4 && params[:birth_date].to_i != 0)
              params[:parsed_birth_date] = params[:birth_date]
            else
              params[:parsed_birth_date] = parse_american_date(params[:birth_date])
            end
          rescue
            error_details << t("invalid_birth_date_format")
          end
        end

        if !params[:entered_on_start].blank?
          begin
            params[:parsed_entered_start_date] = parse_american_date(params[:entered_on_start])
          rescue
            error_details << t("invalid_entered_on_start_date_format")
          end
        end

        if !params[:entered_on_end].blank?
          begin
            params[:parsed_entered_end_date] = parse_american_date(params[:entered_on_end], 1)
          rescue
            error_details << t("invalid_entered_on_end_date_format")
          end
        end

        raise if (!error_details.empty?)

        @cmrs = Event.find_by_criteria(convert_to_search_criteria(params))

        #only paginate if results are found
        @cmrs = @cmrs.paginate(:page => params[:page], :per_page => params[:per_page] || 25) if @cmrs.present?

        if !params[:sw_first_name].blank? || !params[:sw_last_name].blank?
          @first_name = params[:sw_first_name]
          @last_name = params[:sw_last_name]
        elsif !params[:name].blank?
          parse_names_from_fulltext_search
        end

      end
    rescue Exception => ex
      flash.now[:error] = t("problem_with_search_criteria")

      # Debt: Error display details are pretty weak. Good enough for now.
      if (!error_details.empty?)
        flash[:error] += "<ul>"
        error_details.each do |e|
          flash[:error] += "<li>#{e}</li>"
        end
        flash[:error] += "</ul>"
      end
      logger.error ex
    end

    # For some reason can't communicate with template via :locals on the render line.  @show_answers and @export_options are used for csv export to cause
    # formbuilder answers to be output and limit the repeating elements, respectively.
    if !params[:diseases].blank? and params[:diseases].size == 1
      @show_answers = true
      @show_disease_specific_fields = true
      @disease = Disease.find(params[:diseases][0])
    end

    @export_options = params[:export_options] || []

    respond_to do |format|
      format.html
      format.csv { render :layout => false }
    end

  end

  def auto_complete_model_for_city
    entered_city = params[:city]
    @addresses = Address.find(:all,
      :select => "distinct city",
      :conditions => [ "city ILIKE ?",
        entered_city + '%'],
      :order => "city ASC",
      :limit => 10
    )
    render :inline => '<ul><% for address in @addresses %><li id="city_<%= address.city %>"><%= h address.city  %></li><% end %></ul>'
  end

  private

  def parse_names_from_fulltext_search
    name_list = params[:name].split(" ")
    if name_list.size == 1
      @last_name = name_list[0]
    elsif name_list.size == 2
      @first_name, @last_name = name_list
    else
      @first_name, @middle_name, @last_name = name_list
    end
  end

  def parse_american_date(date, offset = 0)
    american_date = '%m/%d/%Y'
    (Date.strptime(date, american_date) + offset).to_s
  end

  def max_search_results
    max_limit = config_option(:max_search_results).to_i
    max_limit <= 0 ? 500 : max_limit
  end

  def convert_to_search_criteria(params)
    Hash[:fulltext_terms,   params[:name],
         :diseases,         params[:diseases],
         :gender,           params[:gender],
         :sw_last_name,     params[:sw_last_name],
         :sw_first_name,    params[:sw_first_name],
         :workflow_state,   params[:workflow_state],
         :birth_date,       params[:parsed_birth_date],
         :entered_on_start, params[:parsed_entered_start_date],
         :entered_on_end,   params[:parsed_entered_end_date],
         :city,             params[:city],
         :county,           params[:county],
         :jurisdiction_ids, params[:jurisdiction_ids],
         :event_type,       params[:event_type],
         :record_number,    params[:record_number],
         :pregnant_id,      params[:pregnant_id],
         :state_case_status_ids, params[:state_case_status_ids],
         :lhd_case_status_ids,   params[:lhd_case_status_ids],
         :sent_to_cdc,           params[:sent_to_cdc],
         :first_reported_PH_date_start, params[:first_reported_PH_date_start],
         :first_reported_PH_date_end,   params[:first_reported_PH_date_end],
         :investigator_ids, params[:investigator_ids],
         :other_data_1,     params[:other_data_1],
         :other_data_2,     params[:other_data_2],
         :limit,            max_search_results]
  end
end
