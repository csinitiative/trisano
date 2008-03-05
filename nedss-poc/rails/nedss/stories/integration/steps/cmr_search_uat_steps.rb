steps_for(:cmr_search_uat) do
    
#    When("I search for all CMRs with the disease '$disease'") do |disease|
#      diseases = Disease.find(:all)
#      diseases.each do |d|
#        if d.disease_name == disease
#          @search_id = d.id
#        end
#      end
#      
#      get "/search/cmrs?disease=#{@search_id}"
#    end
#  
#    Then("I should see at least one result with the disease '$disease'") do |disease|  
#      # Debt: This matching is totally weak. Use Hpricot or something to get at the result.
#      response.should_not have_text(/no results/)
#    end
    
end
