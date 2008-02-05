require File.dirname(__FILE__) + "/helper"

with_steps_for(:people_integration) do
  run_local_story "people_integration_story"
end