require File.dirname(__FILE__) + "/helper"

with_steps_for(:search_uat) do
  run_local_story "search_uat_story", :type => RailsStory
end