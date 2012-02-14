# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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
    @code_names = CodeName.find(:all, :conditions => { :external => true }, :order => 'code_name')
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_names")) unless @code_names
  end

  def index_code
    @code_name = CodeName.find_by_code_name(params[:code_name], :conditions => { :external => true })
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name", :name => params[:code_name])) unless @code_name
    @external_codes = @code_name.external_codes.find(:all, :order => 'the_code')
    respond_to do |format|
      format.html
      format.xml { render :xml => @external_codes }
    end
  end

  def new_code
    @code_name = CodeName.find_by_code_name(params[:code_name], :conditions => { :external => true })
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name", :name => params[:code_name])) unless @code_name
    @external_code = @code_name.external_codes.build
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name_and_code", :name => params[:code_name], :code => params[:the_code])) unless @external_code
  end

  def show_code
    @external_code = ExternalCode.find_by_code_name_and_the_code(params[:code_name], params[:the_code])
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name_and_code", :name => params[:code_name], :code => params[:the_code])) unless @external_code
    @code_name = CodeName.find_by_code_name(params[:code_name], :conditions => { :external => true })
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name", :name => params[:code_name])) unless @code_name
  end

  def update_code
    @external_code = ExternalCode.find_by_code_name_and_the_code(params[:code_name], params[:the_code])
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name_and_code", :name => params[:code_name], :code => params[:the_code])) unless @external_code
    @code_name = CodeName.find_by_code_name(params[:code_name], :conditions => { :external => true })
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name", :name => params[:code_name])) unless @code_name

    if @external_code.update_attributes(params[:external_code])
      redis.delete_matched("views/events/*")

      flash[:notice] = t("external_code_updated")
      redirect_to(show_code_url(@external_code.code_name, @external_code.the_code))
    else
      flash[:error] = t("code_modification_failed")
      render :action => "edit_code"
    end
  end

  def edit_code
    @external_code = ExternalCode.find_by_code_name_and_the_code(params[:code_name], params[:the_code])
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name_and_code", :name => params[:code_name], :code => params[:the_code])) unless @external_code
    @code_name = CodeName.find_by_code_name(params[:code_name], :conditions => { :external => true })
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name", :name => params[:code_name])) unless @code_name
  end

  def create_code
    @code_name = CodeName.find_by_code_name(params[:code_name], :conditions => { :external => true })
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name", :name => params[:code_name])) unless @code_name
    @external_code = ExternalCode.new(params[:external_code])
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name_and_code", :name => params[:code_name], :code => params[:the_code])) unless @external_code

    if @external_code.save
      redis.delete_matched("views/events/*")

      flash[:notice] = t("external_code_created")
      redirect_to(show_code_url(@external_code.code_name, @external_code.the_code))
    else
      flash[:error] = t("code_creation_failed")
      render :action => "new_code"
    end
  end

  def soft_delete_code
    @external_code = ExternalCode.find_by_code_name_and_the_code(params[:code_name], params[:the_code])
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name_and_code", :name => params[:code_name], :code => params[:the_code])) unless @external_code
    @code_name = CodeName.find_by_code_name(params[:code_name], :conditions => { :external => true })
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name", :name => params[:code_name])) unless @code_name

    if @external_code.soft_delete
      redis.delete_matched("views/events/*")

      flash[:notice] = t("external_code_deleted")
      redirect_to(show_code_url(@external_code.code_name, @external_code.the_code))
    else
      flash[:error] = t("code_deletion_failed")
      redirect_to(edit_code_url(@external_code.code_name, @external_code.the_code))
    end
  end

  def soft_undelete_code
    @external_code = ExternalCode.find_by_code_name_and_the_code(params[:code_name], params[:the_code])
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name_and_code", :name => params[:code_name], :code => params[:the_code])) unless @external_code
    @code_name = CodeName.find_by_code_name(params[:code_name], :conditions => { :external => true })
    raise(ActiveRecord::RecordNotFound, t("could_not_find_code_name_for_name", :name => params[:code_name])) unless @code_name

    if @external_code.soft_undelete
      redis.delete_matched("views/events/*")

      flash[:notice] = t("code_restoration_successful")
      redirect_to(show_code_url(@external_code.code_name, @external_code.the_code))
    else
      flash[:error] = t("code_restoration_failed")
      redirect_to(edit_code_url(@external_code.code_name, @external_code.the_code))
    end
  end

end
