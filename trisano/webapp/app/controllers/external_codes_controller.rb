# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

class ExternalCodesController < AdminController
  def index
    @external_codes = ExternalCode.find(:all, :order => "sort_order")
    @code_types = ExternalCode.find(:all,:select => "DISTINCT code_name", :order => "code_name")
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
        format.html {redirect_to code_path(@external_code)}
        format.xml {head :ok}
	    else
        format.html {render :action => "edit"}
        format.xml {render :xml => @external_code.errors, :status => :unprocessable_entity}
	    end
    end
  end

  def destroy
    @external_code = ExternalCode.find(params[:id])
    @external_code.destroy

    respond_to do |format|
      format.html { redirect_to(codes_url) }
	    format.xml  { head :ok }
    end
  end
end
