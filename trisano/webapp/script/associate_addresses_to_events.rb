puts 'Generating longitudinal address data'

InterestedParty.find(:all).each do |ip|
  unless ip.event.try(:address)
    address = ip.person_entity.addresses.first
    if address
      address = address.clone if address.event
      address.event_id =  ip.event_id
      address.save!
    end
  end
end

InterestedPlace.find(:all).each do |ip|
  unless ip.event.try(:address)
    address = ip.place_entity.addresses.first
    if address
      address = address.clone if address.event
      address.event_id = ip.event_id
      address.save!
    end
  end
end
