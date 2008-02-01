ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails/story_adapter'

##
# Run a story file relative to the stories directory
def run_local_story(filename)
  run File.join(File.dirname(__FILE__), filename)
end