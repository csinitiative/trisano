class SearchController < ApplicationController

  def people

    @people = []
    @first_name = ""
    @last_name = ""

    # Is there some more elegant way to do this when you don't want the message hanging around?
    flash[:error] = ""
    
    begin
      if !params[:name].blank? || !params[:birth_date].blank?
        @people = Person.find_by_ts(:fulltext_terms => params[:name], :birth_date => params[:birth_date])
        
        if !params[:name].blank? && @people.empty?
          @first_name, @last_name = params[:name].split(" ")
        end
        
      end
    rescue
      flash[:error] = "There was a problem with your search criteria. Please try again."
    end
        
  end
  
  def cmrs

    @cmrs = []
    @diseases = Disease.find(:all, :order => "disease_name")
    
    flash[:error] = ""
    
    begin
      if !params[:disease].blank? || !params[:name].blank?
        @cmrs = Event.find_by_criteria(:fulltext_terms => params[:name], :disease => params[:disease])
      end
    rescue
      flash[:error] = "There was a problem with your search criteria. Please try again."
    end
        
  end
    
end


