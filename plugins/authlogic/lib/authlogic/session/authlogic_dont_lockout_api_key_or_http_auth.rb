# Fixes known Authlogic bug
# https://github.com/binarylogic/authlogic/issues/35

module Authlogic::Session::Timeout::DontLockoutApiKeyOrHttpAuth
  def self.included(klass)
    klass.class_eval do
      dont_lockout = "single_access? || persist_by_http_auth"
      before_persisting_callback_chain.detect {|c| c.method == :reset_stale_state }.options.update(:unless => dont_lockout)
      after_persisting_callback_chain.detect  {|c| c.method == :enforce_timeout   }.options.update(:unless => dont_lockout)
    end
  end
end

class Authlogic::Session::Base
  include Authlogic::Session::Timeout::DontLockoutApiKeyOrHttpAuth
end
