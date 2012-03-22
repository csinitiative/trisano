# -*- coding: utf-8 -*-
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

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  before_filter :load_user
  before_filter :prep_extensions

  helper_method :static_error_page_path
  helper_method :javascript_include_renderers, :dom_loaded_javascripts
  helper_method :address_extension_renderers
  helper_method :cmr_contacts_extension_renderers, :cmr_place_exposure_extensions
  helper_method :search_extensions
  helper_method :before_core_partials, :after_core_partials, :core_replacement_partial
  helper_method :codes_for_select

  class << self
    def ignore_plugin_renderers?
      @ignore_special_renderers ||= false
    end

    def ignore_plugin_renderers=(value)
      @ignore_special_renderers = value
    end
  end

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store

  # Commented out to allow for auto_complete. http://dev.rubyonrails.org/ticket/10059
  # There are other # ways to resolve this, but going big guns for now.
  #
  # protect_from_forgery # :secret => '2d3bed8e7cbfb7957951219c8ef78101'

  protected

  # preparing as a place for plugins to hook
  def default_url_options(options={})
    {}
  end

  # Debt: Used by nested resources of events, so it assumes the event id is in the params as event_id
  def can_view_event?
    @event ||= Event.find(params[:event_id])
    unless User.current_user.is_entitled_to_in?(:view_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
      render :partial => 'events/permission_denied', :locals => { :reason => t("no_view_privs_for_jurisdiction"), :event => @event }, :layout => true, :status => 403 and return
    end
  end

  # Debt: Used by nested resources of events, so it assumes the event id is in the params as event_id
  def can_update_event?
    @event ||= Event.find(params[:event_id])
    unless User.current_user.is_entitled_to_in?(:update_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
      render :partial => 'events/permission_denied', :locals => { :reason => t("no_update_privs_for_jurisdiction"), :event => @event }, :layout => true, :status => 403 and return
    end
  end

  # Debt: Used by nested resources of events, so it assumes the event id is in the params as event_id
  def find_event
    begin
      @event = Event.find(params[:event_id])
    rescue => error
      respond_to do |format|
        format.html do
          render :file => static_error_page_path(404), :layout => 'application', :status => 404 and return
        end
        format.xml { head :not_found }
      end
    end
  end


  #
  # Logging a bit chatty just for initial deployments. We can turn it down later.
  #

  def load_user
    auth_src_env = config_option(:auth_src_env)
    auth_src_header = config_option(:auth_src_header)

    if !session[:user_id].nil?
      I18nLogger.info("logger.using_user_in_session")
      load_user_by_uid(session[:user_id])
    elsif !auth_src_env.blank?
      I18nLogger.info("logger.using_user_in_env_variable", :auth_src_env => auth_src_env)
      load_user_by_uid(user_from_env(auth_src_env))
    elsif !auth_src_header.blank?
      I18nLogger.info("logger.using_user_in_header", :auth_src_header => auth_src_header)
      load_user_by_uid(request.headers[auth_src_header])
    else
      I18nLogger.info("logger.no_uid_present")
      log_request_info
      render :text => t("no_uid_present"), :status => 403
      return
    end
  end

  def load_user_by_uid(uid)

    if uid.blank?
      I18nLogger.info("logger.no_uid_present")
      log_request_info
      render :text => t("no_uid_present"), :status => 403
      return
    end

    I18nLogger.info("logger.attempting_to_load_user", :uid => uid)
    User.current_user = User.find_by_uid(uid)

    if User.current_user.nil?
      I18nLogger.info("logger.user_not_found", :uid => uid)
      log_request_info
      render :text => t("user_not_found", :uid => uid), :status => 403
      return
    end

    if User.current_user.disabled?
      I18nLogger.info("logger.login_attempt_with_disabled_uid", :uid => uid)
      log_request_info
      render :text => t("account_not_avaliable")
      return
    end

    I18nLogger.info("logger.user_loaded", :uid => User.current_user.uid)
    User.current_user
  end

  def log_request_info
    thread_id = Thread.current.object_id
    request.env.each do |key, value|
      logger.info "#{thread_id} -- #{key}: #{value}"
    end
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

  def prep_extensions
    @extension_action_links = []
  end

  # optional renderers for replacing core fields.
  # Debt: Probably should move API bits into their own module
  # PLUGIN_API
  def before_core_partials
    return Hash.new {|hash, key| hash[key] = []} if ApplicationController.ignore_plugin_renderers?
    @before_core_partials ||= Hash.new {|hash, key| hash[key] = []}
  end

  def after_core_partials
    return Hash.new {|hash, key| hash[key] = []} if ApplicationController.ignore_plugin_renderers?
    @after_core_partials ||= Hash.new {|hash, key| hash[key] = []}
  end

  def core_replacement_partial
    return {} if ApplicationController.ignore_plugin_renderers?
    @replace_core_partials ||= {}
  end

  # PLUGIN_API render for add javascript_include_tags
  def javascript_include_renderers
    return [] if ApplicationController.ignore_plugin_renderers?
    @javascript_include_renderers ||= []
  end

  # javascript included in this array will be executed on dom:loaded
  def dom_loaded_javascripts
    return [] if ApplicationController.ignore_plugin_renderers?
    @dom_loaded_javascripts ||= []
  end

  # enhancements for address partials
  def address_extension_renderers
    return [] if ApplicationController.ignore_plugin_renderers?
    @address_extension_renderers ||= []
  end

  def cmr_contacts_extension_renderers
    return [] if ApplicationController.ignore_plugin_renderers?
    @cmr_contacts_extension_renderers ||= []
  end

  def cmr_place_exposure_extensions
    return [] if ApplicationController.ignore_plugin_renderers?
    @cmr_place_exposure_extensions ||= []
  end

  def search_extensions
    return [] if ApplicationController.ignore_plugin_renderers?
    @search_extensions ||= []
  end

  def codes_for_select(code_name)
    code_select_cache.drop_down_selections(code_name, @event)
  end

  private

  def user_from_env(auth_src_env)
    if RAILS_ENV == "development" || RAILS_ENV == "test" || RAILS_ENV == "uattest" || RAILS_ENV == "feature"
      ENV[auth_src_env].blank? ? 'default' : ENV[auth_src_env]
    else
      ENV[auth_src_env]
    end
  end

  # Accepts an error code (403, 404, etc.) and returns a path to a static HTML
  # file.
  def static_error_page_path(error)
    locale_specific_path = "#{RAILS_ROOT}/public/#{error}.#{I18n.locale.to_s}.html"
    default_path = "#{RAILS_ROOT}/public/#{error}.html"
    default_500_path = "#{RAILS_ROOT}/public/500.html"

    if File.exists?(locale_specific_path)
      return locale_specific_path
    elsif File.exists?(default_path)
      return default_path
    else
      return default_500_path
    end

  end

  def code_select_cache
    @code_select_cache ||= CodeSelectCache.new
  end
end
