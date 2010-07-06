# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

class UserSessionsController < ApplicationController
  reloadable!

  skip_before_filter :load_user, :only => [:new, :create]
  prepend_before_filter :destroy_session, :only => [:new, :create]

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Successfully logged in."
      redirect_to home_url
    else
      render :action => 'new'
    end
  end

  def destroy
    User.current_user = nil
    @user_session = UserSession.find
    @user_session.destroy
    flash[:notice] = "Successfully logged out."
    redirect_to login_url
  end

  protected

  def destroy_session
    User.current_user = nil
    @user_session.try(:destroy)
  end
  
end
