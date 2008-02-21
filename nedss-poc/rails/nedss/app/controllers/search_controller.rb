class SearchController < ApplicationController
  
  def index
   
    @people = []
    
    # Yes, last minute kludge. Where does the error go when you don't have a model?
    flash[:notice] =""
    
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