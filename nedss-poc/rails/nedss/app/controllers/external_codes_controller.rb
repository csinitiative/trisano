class ExternalCodesController < ApplicationController
    def index
        @external_codes = ExternalCode.find(:all)
	respond_to do |format|
            format.html
	    format.xml
	end
    end

    def show
        @external_code = ExternalCode.find(params[:id])
	respond_to do |format|
            format.html
	    format.xml
	end
    end

    def edit
        @external_code = ExternalCode.find(params[:id])
    end

    def update
        @external_code = ExternalCode.find(params[:id])
	respond_to do |format|
	    if @external_code.update_attributes(params[:external_code])
                flash[:notice] = "Code was successfully updated"
	        format.html {redirect_to code_path}
	        format.xml {head :ok}
	    else
                format.html {render :action => "edit"}
		format.xml {render :xml => @external_code.errors, :status => :unprocessable_entity}
	    end
	end
    end
end
