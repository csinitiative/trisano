class ExternalCodesController < ApplicationController
    def index
        @external_codes = ExternalCode.find(:all, :conditions => "current = TRUE")
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

    def new
        @external_code = ExternalCode.new(@default_values)

	respond_to do |format|
            format.html
	    format.xml {render :xml => @external_code}
	end
    end

    def create
        @external_code = ExternalCode.new(params[:external_code])

	respond_to do |format|
	    if @external_code.save
	        flash[:notice] = "Code was successfully created."
		format.html { redirect_to(code_url(@external_code)) }
                format.xml  { render :xml => @external-code, :status => :created, :location => @external_code }
	    else
	        format.html { render :action => "new" }
		format.xml  { render :xml => @external_code.errors, :status => :unprocessable_entity }
            end
	end
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
