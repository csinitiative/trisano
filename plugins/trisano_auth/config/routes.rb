# Copyright (C) 2009, 2010, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

ActionController::Routing::Routes.draw do |map|

  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.change_password 'change_password', :controller => 'user_sessions', :action => 'change'
  map.resources :user_sessions
  map.resources :password_resets, :only => [:index, :new, :edit, :update, :change]

  map.api_key 'users/settings/api_key', :controller => 'users', :action => 'api_key'
end
