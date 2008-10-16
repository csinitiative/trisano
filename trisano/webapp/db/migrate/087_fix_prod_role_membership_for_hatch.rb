class FixProdRoleMembershipForHatch < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == "production"
      transaction do
        execute("DELETE FROM role_memberships WHERE jurisdiction_id IS NULL")
      end
    end
  end

  def self.down
  end
end
