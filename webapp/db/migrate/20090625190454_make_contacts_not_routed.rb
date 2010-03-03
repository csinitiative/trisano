class MakeContactsNotRouted < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      ContactEvent.update_all("workflow_state = 'not_routed'", "workflow_state = 'new'")
    end
  end

  def self.down
  end
end
