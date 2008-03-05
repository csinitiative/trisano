require File.dirname(__FILE__) + "/helper"

with_steps_for(:cmr_search_uat) do
  run_local_story "cmr_search_uat_story", :type => RailsStory
end