class SearchController < ApplicationController

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

    @cmrs = []
    @first_name = ""
    @middle_name = ""
    @last_name = ""
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

    flash[:error] = ""
    
    begin
      if !params[:disease].blank? || !params[:name].blank? || !params[:gender].blank? || !params[:investigation_status].blank?
        @cmrs = Event.find_by_criteria(:fulltext_terms => params[:name], 
                                       :disease => params[:disease],
                                       :gender => params[:gender]
                                      )
        
       if !params[:name].blank? && @cmrs.empty?
          parse_names_from_fulltext_search
        end
      end
    rescue
      flash[:error] = "There was a problem with your search criteria. Please try again."
    end
        
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
    
end


