# Copyright (C) 2009, 2010, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition..

class UserSession < Authlogic::Session::Base
  reloadable!
  logout_on_timeout true
end