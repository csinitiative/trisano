class SearchController < ApplicationController
  
  def index
   
    @people = []
    
    begin
      if !params[:name].blank? || !params[:birth_date].blank?
        @people = Person.find_by_ts(:fulltext_terms => params[:name], :birth_date => params[:birth_date])
      end
    rescue
      # Debt? This is an error. Is there someplace better to stuff it?
      flash[:notice] = "There was a problem with your search criteria. Please try again."
    end
    
  end
  
end