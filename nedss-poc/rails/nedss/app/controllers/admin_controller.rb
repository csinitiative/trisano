class AdminController < ApplicationController
  
    before_filter :check_role
    
    def index
      # Nothing to do at the moment as the dashboard is static
    end
  
    protected
    
    def check_role
      if !User.current_user.is_admin?
        logger.info "Unauthorized access to the Admin Console by " + User.current_user.user_name
        redirect_to "/403.html"
        return
      end
    end
    
end
