class AddDispositionDateToParticipationsContacts < ActiveRecord::Migration
  def self.up
    add_column :participations_contacts, :disposition_date, :date
  end

  def self.down
    remove_column :participations_contacts, :disposition_date, :date
  end
end
