class AddOccupationToRiskFactors < ActiveRecord::Migration
  def self.up
    add_column :participations_risk_factors, :occupation, :string
  end

  def self.down
    remove_column :participations_risk_factors, :occupation
  end
end
