# Copyright (C) 2009, 2010, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition..

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
