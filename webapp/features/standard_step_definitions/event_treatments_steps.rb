Given /^the morbidity event has the following treatments:$/ do |table|
  table.hashes.each do |hash|
    participations_treatment = Factory.create(:participations_treatment, :treatment => Factory.create(:treatment, hash))
    @event.interested_party.treatments << participations_treatment
  end
end

Given /^the contact event has the following treatments:$/ do |table|
  table.hashes.each do |hash|
    participations_treatment = Factory.create(:participations_treatment, :treatment => Factory.create(:treatment, hash))
    @event.contact_child_events.first.interested_party.treatments << participations_treatment
  end
end

Given /^the encounter event has the following treatments:$/ do |table|
  table.hashes.each do |hash|
    participations_treatment = Factory.create(:participations_treatment, :treatment => Factory.create(:treatment, hash))
    @encounter.interested_party.treatments << participations_treatment
  end
end

# Local Variables:
# mode: ruby
# tab-width: 2
# ruby-indent-level: 2
# indent-tabs-mode: nil
# End:
