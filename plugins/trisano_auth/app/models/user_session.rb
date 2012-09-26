# Copyright (C) 2009, 2010, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition..

class UserSession < Authlogic::Session::Base
  reloadable!
  logout_on_timeout true
  consecutive_failed_logins_limit 3
  failed_login_ban_for 2.hours
  single_access_allowed_request_types :all
  params_key "api_key"
end
