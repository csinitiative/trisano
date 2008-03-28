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
   
  # MJH 30-DEC just hacking for now - may be a rails bug - researching
  # See http://wiki.csinitiative.com/moin/NedssRailsPoc/PackagingAsWarFile
  
  before_filter :load_user
  
  protected
  
  #
  # Logging a bit chatty just for initial deployments. We can turn it down later.
  # 
  
  def load_user
    if NEDSS_UID.blank?
      logger.info "Attempting to locate user information on the request"
      if RAILS_ENV == "production"
        logger.info "Using HTTP_UID header"
        load_user_by_uid(request.headers["HTTP_UID"])
      else
        logger.info "Using REMOTE_USER"
        load_user_by_uid(request.env["REMOTE_USER"])
      end
    else
      logger.info "Using NEDSS user found in local environment variable"
      load_user_by_uid(NEDSS_UID)
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
    logger.info "User loaded: " + User.current_user.uid
    User.current_user
  end
  
  def log_request_info
    thread_id = Thread.current.object_id
    request.env.each do |key, value|
      logger.info "#{thread_id} -- #{key}: #{value}"
    end      
  end
  
end
