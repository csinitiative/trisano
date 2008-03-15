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
        @people = Person.find_by_ts(:fulltext_terms => params[:name], :birth_date => params[:birth_date])
        
        if !params[:name].blank? && @people.empty?
          parse_names_from_fulltext_search
        end
        
      end
    rescue
      flash[:error] = "There was a problem with your search criteria. Please try again."
    end
        
  end
  
  def cmrs

    flash[:error] = ""
    error_details = []
    
    @first_name = ""
    @middle_name = ""
    @last_name = ""
    @birth_date = ""
    @diseases = Disease.find(:all, :order => "disease_name")
    @genders = Code.find(:all, 
                         :order => "id", 
                         :select => "id, code_description", 
                         :conditions => "code_name = 'gender'" )

    @genders << Code.new(:id => "U", :code_description => "Unspecified")
    
    @investigation_statuses = Code.find(:all,
                                       :order => "id",
					:select => "id, code_description",
					:conditions => "code_name = 'investigation'")
    @investigation_statuses << Code.new(:id => "U", :code_description => "Unspecified")
    
    @counties = Code.find(:all,
                          :order => "id",
                          :select => "id, code_description",
                          :conditions => "code_name = 'county'")

    
    @districts = Code.find(:all,
                           :order => "id",
                           :select => "id, code_description",
                           :conditions => "code_name = 'district'")
    
    begin
     if not params.values_blank?
        
        if !params[:birth_date].blank?
          begin
            if (params[:birth_date].length == 4)
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
                                       :investigation_status => params[:investigation_status],
                                       :birth_date => @birth_date,
                                       :entered_on_start => entered_on_start,
                                       :entered_on_end => entered_on_end,
                                       :city_id => params[:city_id],
                                       :county => params[:county],
                                       :district => params[:district]
                                      )
           
           if (@cmrs.blank?)
              if !params[:sw_first_name].blank? || !params[:sw_last_name].blank?
                @first_name = params[:sw_first_name]
                @last_name = params[:sw_last_name]
              elsif !params[:name].blank?
                parse_names_from_fulltext_search
              end
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
  end
  
  def auto_complete_model_for_city
    entered_city = params[:city]
    @cities = Code.find(:all, 
                        :select => "id, code_description", 
                        :conditions => [ "LOWER(code_description) LIKE ? and code_name = 'city'", 
                          entered_city.downcase + '%'],
                        :order => "code_description ASC",
                        :limit => 10
                       )
    render :inline => '<ul><% for city in @cities %><li id="city_id_<%= city.id %>"><%= h city.code_description %></li><% end %></ul>'
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