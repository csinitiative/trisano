puts 'Generating longitudinal address data'

puts "  * Processing human events"
i = 0
HumanEvent.find_in_batches(:include => [ :interested_party => { :person_entity => :addresses } ], :conditions => "participations.id IS NOT NULL", :batch_size => 500 ) do |event_group|
  i += 1
  puts "    * Processing #{i.ordinalize} group of 500 human events"
  event_group.each do | event |
    unless event.try(:address)
      address = event.interested_party.person_entity.addresses.first
      if address
        address = address.clone if address.event
        address.event_id =  event.id
        address.save!
      end
    end
  end
end

i = 0
PlaceEvent.find_in_batches(:include => [ :interested_place => { :place_entity => :addresses } ], :conditions => "participations.id IS NOT NULL", :batch_size => 500 ) do |event_group|
  i += 1
  puts "    * Processing #{i.ordinalize} group of 500 place events"
  event_group.each do | event |
    unless event.try(:address)
      address = event.interested_place.place_entity.addresses.first
      if address
        address = address.clone if address.event
        address.event_id =  event.id
        address.save!
      end
    end
  end
end
