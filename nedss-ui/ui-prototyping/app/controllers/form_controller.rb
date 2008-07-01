class FormController < ApplicationController
  def index
    @boolean_example = true
    @user_name = "User"
    @user = Dude.new
  end
end

class Dude
  attr_accessor :name, :wife
  
  def initialize
    @name = "Cool Guy"
    @wife = Wife.new
  end
  
end

class Wife
  attr_accessor :is_cool

  def initialize
    @is_cool = true
  end
  
end
