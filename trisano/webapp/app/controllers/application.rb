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
  
  #
  # Logging a bit chatty just for initial deployments. We can turn it down later.
  # 
  
  def load_user
    if TRISANO_UID.blank?
      logger.info "Attempting to locate user information on the request"
      if RAILS_ENV == "production"
        logger.info "Using HTTP_UID header"
        load_user_by_uid(request.headers["HTTP_UID"])
      else
        if session[:user_id].nil?
          logger.info "Using REMOTE_USER"
          load_user_by_uid(request.env["REMOTE_USER"])
        else
          logger.info "Using session information"
          load_user_by_uid(session[:user_id])
        end
      end
    else
      if session[:user_id].nil?
        logger.info "Using NEDSS user found in local environment variable"
        load_user_by_uid(TRISANO_UID)
      else
        logger.info "Using user set in session"
        load_user_by_uid(session[:user_id])
      end
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
  
  def rescue_action_in_public(exception)
    render :text => "<html><body bgcolor='#ededed'><br/><table bgcolor='#000000' width='500' cellspacing='1' cellpadding='10' align='center'>
<tr bgcolor='#ffffff'><td style='font-family: verdana, sans-serif'><h3>Application Error</h3>
<p style='font-size: 12px'>An error occurred while your request was being processed.<br/><br/>#{Time.now.to_s} #{exception}</p><br/><hr/>
<b style='font-size: 12px'>Release 1 Pilot Feedback:</b>&nbsp;
<a href='https://ut-nedss.csinitiative.net/wiki/Release1PilotFeedback' style='font-size: 12px'>Wiki</a>&nbsp;
<a href='mailto:r1feedback@ut-nedss.csinitiative.net' style='font-size: 12px'>Email List</a>
</td></tr></table></body></html>" 
  end


end
