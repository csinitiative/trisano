class User < ActiveRecord::Base
  
  def self.current_user=(user)
    Thread.current[:user] = user
  end

  def self.current_user
    Thread.current[:user]
  end
  
end
