xml.instruct!
CoreField.find_event_fields_for('morbidity_event', :order => 'lft ASC').select { |cf| cf.rendered_on_event?(@event) }.each do |cf|

end
