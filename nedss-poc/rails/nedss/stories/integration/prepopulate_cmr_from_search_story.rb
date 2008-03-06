require File.dirname(__FILE__) + "/helper"

with_steps_for(:prepopulate_cmr_uat) do
  run_local_story "prepopulate_cmr_from_search_story", :type => RailsStory
end
