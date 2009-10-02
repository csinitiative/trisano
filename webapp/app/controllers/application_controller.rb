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

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store

  # Commented out by Pete Lacey to allow for auto_complete. http://dev.rubyonrails.org/ticket/10059
  # There are other # ways to resolve this, but going big guns for now.
  #
  # protect_from_forgery # :secret => '2d3bed8e7cbfb7957951219c8ef78101'

  before_filter :load_user

  protected

  # Debt: Used by nested resources of events, so it assumes the event id is in the params as event_id
  def can_view_event?
    @event ||= Event.find(params[:event_id])
    unless User.current_user.is_entitled_to_in?(:view_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
      render :partial => 'events/permission_denied', :locals => { :reason => "You do not have view privileges for this jurisdiction", :event => @event }, :layout => true, :status => 403 and return
    end

  end

  # Debt: Used by nested resources of events, so it assumes the event id is in the params as event_id
  def can_update_event?
    @event ||= Event.find(params[:event_id])
    unless User.current_user.is_entitled_to_in?(:update_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
      render :partial => 'events/permission_denied', :locals => { :reason => "You do not have update privileges for this jurisdiction", :event => @event }, :layout => true, :status => 403 and return
    end
  end

  # Debt: Used by nested resources of events, so it assumes the event id is in the params as event_id
  def find_event
    begin
      @event = Event.find(params[:event_id])
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => 'application', :status => 404 and return
    end
  end


  #
  # Logging a bit chatty just for initial deployments. We can turn it down later.
  #

  def load_user
    auth_src_env = config_option(:auth_src_env)
    auth_src_header = config_option(:auth_src_header)

    if !session[:user_id].nil?
      logger.info "Using user set in session"
      load_user_by_uid(session[:user_id])
    elsif !auth_src_env.blank?
      logger.info "Using TriSano user found in #{auth_src_env} environment variable"
      load_user_by_uid(ENV[auth_src_env])
    elsif !auth_src_header.blank?
      logger.info "Using TriSano user found in #{auth_src_header} http header"
      load_user_by_uid(request.headers[auth_src_header])
    else
      logger.info "No UID is present"
      log_request_info
      render :text => "Internal application error: No UID is present. Please contact your administrator.", :status => 500
      return
    end
  end

  def load_user_by_uid(uid)

    if uid.blank?
      logger.info "No UID is present"
      log_request_info
      render :text => "Internal application error: No UID is present. Please contact your administrator.", :status => 500
      return
    end

    logger.info "Attempting to load user with a UID of " + uid
    User.current_user = User.find_by_uid(uid)

    if User.current_user.nil?
      logger.info "User not found by uid: " + uid
      log_request_info
      render :text => "Internal application error: User not found. Please contact your administrator.", :status => 500
      return
    end

    if User.current_user.disabled?
      logger.info "Login attempt with disabled UID " +  uid
      log_request_info
      render :text => "This account is not currently available. Please contact your administrator."
      return
    end

    logger.info "User loaded: " + User.current_user.uid
    User.current_user
  end

  def log_request_info
    thread_id = Thread.current.object_id
    request.env.each do |key, value|

      logger.info "#{thread_id} -- #{key}: #{value}"
    end
  end

  def rescue_action_in_public(exception)
    # The following can be made to render the 500.html view once we upgrade Rails.
    # Issue with rendering error pages w/Tomcat WAR deployments in pre-Rails 2.1:
    #   http://www.ruby-foru​m.com/topic/167228

    render :text => "<html><body bgcolor='#ededed'><br/><table bgcolor='#000000' width='500' cellspacing='1' cellpadding='10' align='center'>
<tr bgcolor='#ffffff'><td style='font-family: verdana, sans-serif'><h2>TriSano</h2><hr/><h3>Application Error</h3>
<p style='font-size: 12px'>An error occurred while your request was being processed.</p><br/><hr/>
<b style='font-size: 12px'><a href='https://wiki.csinitiative.com/display/tri/Feedback' style='font-size: 12px'>Provide feedback</a></b>
</td></tr></table></body></html>"
  end

  # Kluge to get around the fact that Rails does not reset objects in
  # memory after a failed transaction, thus interfering with behavior
  # of form helpers. Creates a new object from request parameters
  # and copies over any existing errors from the original object.
  def post_transaction_refresh(obj, params)
    errors = obj.errors
    obj = obj.class.new(params)
    errors.each do |error_key, error_value|
      obj.errors.add(error_key, error_value)
    end
    obj
  end

end
