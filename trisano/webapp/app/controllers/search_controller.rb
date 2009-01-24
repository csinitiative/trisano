# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

  def people

    @people = []
    @first_name = ""
    @middle_name = ""
    @last_name = ""

    # Is there some more elegant way to do this when you don't want the message hanging around?
    flash[:error] = ""
    
    begin
      if !params[:name].blank? || !params[:birth_date].blank?
        people = Person.find_by_ts(:fulltext_terms => params[:name], :birth_date => params[:birth_date])
        
        unless people.empty?
          @people = people.collect do |person|
            event = Event.find(:first, :include => "participations", :conditions => ["participations.primary_entity_id = ? and participations.role_id = ?", person.entity_id, Event.participation_code('Interested Party')] )
            if event.nil?
              type = "No associated event"
              id = nil
              deleted_at = nil
            else
              type = event[:type]
              id = event.id
              deleted_at = event.deleted_at
            end
            { :person => person, :event_type => type, :event_id => id, :deleted_at => deleted_at }
          end
        end

        parse_names_from_fulltext_search
                
      end
    rescue
      flash[:error] = "There was a problem with your search criteria. Please try again. #{$!}"
    end
        
  end
  
  def cmrs

    flash[:error] = ""
    error_details = []
    
    @jurisdictions = User.current_user.jurisdictions_for_privilege(:view_event)
    if @jurisdictions.nil?
      error_details << "You do not have view permissions in any jurisdiction"
    end

    @first_name = ""
    @middle_name = ""
    @last_name = ""
    @birth_date = ""
    @event_types = [ {:name => "Morbidity Event (CMR)", :value => "MorbidityEvent"}, {:name => "Contact Event", :value => "ContactEvent"} ]
    @diseases = Disease.find(:all, :order => "disease_name")
    @genders = ExternalCode.find(:all, :select => "id, code_description", :conditions => "code_name = 'gender'", :order => "id")

    @genders << ExternalCode.new(:id => "U", :code_description => "Unspecified")
    
    @event_statuses = Event.get_states_and_descriptions

    @counties = ExternalCode.find(:all, :select => "id, code_description", :conditions => "code_name = 'county'", :order => "id")

    begin
     if not params.values_blank?
        
        if !params[:birth_date].blank?
          begin
            if (params[:birth_date].length == 4 && params[:birth_date].to_i != 0)
              @birth_date = params[:birth_date]
            else
              @birth_date = parse_american_date(params[:birth_date])
            end
          rescue
            error_details << "Invalid birth date format"
          end
        end
        
        if !params[:entered_on_start].blank?
          begin
            entered_on_start = parse_american_date(params[:entered_on_start])
          rescue
            error_details << "Invalid entered-on start date format"
          end
        end
        
        if !params[:entered_on_end].blank?
          begin
            entered_on_end = parse_american_date(params[:entered_on_end])
          rescue
            error_details << "Invalid entered-on end date format"
          end
        end
        
        raise if (!error_details.empty?)
        
        @cmrs = Event.find_by_criteria(:fulltext_terms => params[:name], 
                                       :disease => params[:disease],
                                       :gender => params[:gender],
                                       :sw_last_name => params[:sw_last_name],
                                       :sw_first_name => params[:sw_first_name],
                                       :event_status => params[:event_status],
                                       :birth_date => @birth_date,
                                       :entered_on_start => entered_on_start,
                                       :entered_on_end => entered_on_end,
                                       :city => params[:city],
                                       :county => params[:county],
                                       :jurisdiction_id => params[:jurisdiction_id],
                                       :event_type => params[:event_type]
                                      )
           
       if !params[:sw_first_name].blank? || !params[:sw_last_name].blank?
         @first_name = params[:sw_first_name]
         @last_name = params[:sw_last_name]
       elsif !params[:name].blank?
         parse_names_from_fulltext_search
       end
            
     end
    rescue Exception => ex
      flash[:error] = "There was a problem with your search criteria"
      
      # Debt: Error display details are pretty weak. Good enough for now.
      if (!error_details.empty?)
        flash[:error] += "<ul>"
        error_details.each do |e|
          flash[:error] += "<li>#{e}</li>"
        end
        flash[:error] += "</ul>"
      end
    end      
    
    # For some reason can't communicate with template via :locals on the render line.  @show_answers and @export_options are used for csv export to cause 
    # formbuilder answers to be output and limit the repeating elements, respectively.
    @show_answers = !params[:disease].blank?
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
  
  def parse_american_date(date)
     american_date = '%m/%d/%Y'
     Date.strptime(date, american_date).to_s
  end
    
end
