Given /^the morbidity event has the following treatments:$/ do |table|
  table.hashes.each do |hash|
    # @participations_treatment = Factory.create(:participations_treatment, :treatment => Factory.create(:treatment, hash))
    participations_treatment = Factory.create(:participations_treatment, :treatment => Factory.create(:treatment, hash))
    @event.interested_party.treatments << participations_treatment
  end
end

Given /^the contact event has the following treatments:$/ do |table|
  table.hashes.each do |hash|
    participations_treatment = Factory.create(:participations_treatment, :treatment => Factory.create(:treatment, hash))
    @contact_event.interested_party.treatments << participations_treatment
  end
end
