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
end
