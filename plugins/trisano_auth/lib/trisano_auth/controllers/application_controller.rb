# Copyright (C) 2009, 2010, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition..

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
        base.alias_method_chain :load_user, :authlogic
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
    end

  end
end

