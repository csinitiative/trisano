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

class UsersController < AdminController
  skip_before_filter :check_role, :only => [:shortcuts, :shortcuts_edit, :shortcuts_update, 'settings']

  def index
    @users = User.all :order => {
      'uid ASC'        => 'uid ASC',
      'uid DESC'       => 'uid DESC',
      'status ASC'     => 'status ASC',
      'status DESC'    => 'status DESC',
      'user_name ASC'  => 'user_name ASC',
      'user_name DESC' => 'user_name DESC'
    }["#{params[:sort_by]} #{params[:sort_direction]}"] || 'uid ASC'

    respond_to do |format|
      format.html
      format.xml  { render :xml => @users }
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @user }
    end
  end

  def new
    @user = User.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @user }
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = t("user_successfully_created")
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def shortcuts
    @user = User.current_user
    response.headers['X-JSON'] = @user.shortcut_settings.to_json
    head :ok
  end

  def shortcuts_edit
    @user = User.current_user
    respond_to do |format|
      format.html
    end
  end

  def shortcuts_update
    @user = User.current_user

    respond_to do |format|
      if @user.update_attribute(:shortcut_settings, params[:user][:shortcut_settings])
        flash[:notice] = t("shortcuts_successfully_updated")
      else
        flash[:error] = t("shortcuts_update_failed")
      end
    format.html { render :action => "shortcuts_edit" }
    end
  end

  def settings
    respond_to do |format|
      format.html
    end
  end

  def create_email_address
    email_address = params[:email_address]
    respond_to do |format|
      format.html do
        new_address = User.current_user.email_addresses.build :email_address => email_address
        if new_address.save
          flash[:notice] = I18n.translate :added_email_address
        else
          flash[:error] = I18n.translate :error_adding_email_address
        end
        redirect_to email_addresses_path
      end
    end
  end

  def update
    params[:user][:role_membership_attributes] ||= {}
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = t("user_successfully_updated")
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end


  def destroy
    head :method_not_allowed
  end

end
