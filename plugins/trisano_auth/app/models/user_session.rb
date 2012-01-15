# Copyright (C) 2009, 2010, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition..

class UserSession < Authlogic::Session::Base
  reloadable!
  single_access_allowed_request_types :all
  params_key "api_key"
end
