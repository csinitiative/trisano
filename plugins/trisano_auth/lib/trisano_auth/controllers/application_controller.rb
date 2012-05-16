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

module TrisanoAuth
  module Controllers
    module ApplicationController
      reloadable!
      hook! 'ApplicationController'

      def load_user_with_authlogic
        if current_user
          User.current_user = @current_user
        else
          redirect_to login_url
          return false
        end
      end

      def self.included(base)
        base.alias_method_chain :load_user, :authlogic unless RAILS_ENV == "feature" || RAILS_ENV == "test"
      end

      private
      def current_user_session
        return @current_user_session if defined?(@current_user_session)
        @current_user_session = UserSession.find
      end

      def current_user
        return @current_user if defined?(@current_user)
        @current_user = current_user_session && current_user_session.user
      end
      
      def require_no_user

        # Without this, processes can still have previous request's User.current_user for actions
        # that do not use :load_user
        User.current_user = nil

        if current_user
          flash[:notice] = "You must be logged out to access this page"
          redirect_to home_url
          return false
        end
      end

      def single_access_allowed?
        true
      end
    end

  end
end

