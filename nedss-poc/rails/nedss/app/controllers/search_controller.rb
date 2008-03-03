class SearchController < ApplicationController

  def index

    @people = []

    # Is there some more elegant way to do this when you don't want the message hanging around?
    flash[:error] = ""
    
    begin
      if !params[:name].blank? || !params[:birth_date].blank?
        @people = Person.find_by_ts(:fulltext_terms => params[:name], :birth_date => params[:birth_date])
      end
    rescue
      flash[:error] = "There was a problem with your search criteria. Please try again."
    end
        
  end
    
end



