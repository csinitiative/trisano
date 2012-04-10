# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the terms of the
# GNU Affero General Public License as published by the Free Software Foundation, either 
# version 3 of the License, or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# See the GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License along with TriSano. 
# If not, see http://www.gnu.org/licenses/agpl3.0.txt.

class PasswordResetsController < ApplicationController
  reloadable!
  skip_before_filter :load_user, :only => [:edit, :update]
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]  
  before_filter :require_no_user, :only => [:edit, :update]
  
  def new
    @user = User.find(params[:user_id])
    @user.reset_perishable_token!
  end

  def edit  
    render  
  end  

  def update  
    @user.password = params[:user][:password]  
    @user.password_confirmation = params[:user][:password_confirmation]  
    if @user.save
      Rails.logger.info "Reset password for #{@user.inspect}" 
      @user.reset_perishable_token!  # invalidate used token
      flash[:notice] = "Password successfully updated"  
      redirect_to home_url  
    else  
      render :action => :edit  
    end  
  end
  
  def index
    @users = User.all
  end

  protected
  
  def access_granted?
    super && User.current_user.is_admin?
  end  
  
  private
  
  def load_user_using_perishable_token 

    # Will check token is found and that user's updated at field
    # is within the time specified by config_options[:trisano_auth][:password_reset_timeout].minutes 
    @user = User.find_using_perishable_token(params[:id])  
   
    Rails.logger.info "Granted #{@user.inspect} access via perishable token."

    unless @user  
      flash[:notice] = "We're sorry, but we could not locate your account. " +  
      "If you are having issues try copying and pasting the URL " +  
      "from your email into your browser or restarting the " +  
      "reset password process."  
      redirect_to login_url  
    end  
  end
end
