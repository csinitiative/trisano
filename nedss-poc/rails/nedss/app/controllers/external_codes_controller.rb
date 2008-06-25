class ExternalCodesController < ApplicationController
    before_filter :can_update?, :only => [:edit, :update, :destroy]
    before_filter :can_view?, :only => [:show]

    def index
        @external_codes = ExternalCode.find(:all)
	respond_to do |format|
            format.html
	    format.xml
	end
    end
end
