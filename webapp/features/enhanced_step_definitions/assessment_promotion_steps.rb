When /^I promote the assessment to a morbidity event$/ do
 When "I click the \"Promote to CMR\" link and accept the confirmation"

  # we want to make available the promoted event at a later time
  # but only if the promotion was successful
   #
   # get_location returns "http://localhost:8080/trisano/cmrs/849"
   # cmr_url returns ""http://www.example.com/cmrs/849" 
   # use cmr_path to check for partial match
  if @browser.get_location.include?(cmr_path(@event))
    #Then reload the event to make it available for other steps
    @promoted_event = MorbidityEvent.find(@event.id)
  end
end

Then /^I should see all of the promoted core field config questions$/ do
  html_source = @browser.get_html_source
  @promoted_core_fields ||= CoreField.all(:conditions => ['event_type = ? AND fb_accessible = ? AND disease_specific = ? AND repeater = FALSE', @promoted_event.type.underscore, true, false])
  @promoted_core_fields.each do |core_field|
    raise "Could not find before config for #{core_field.key}" if html_source.include?("#{core_field.key} before?") == false
    raise "Could not find after config for #{core_field.key}" if html_source.include?("#{core_field.key} after?") == false
  end
end

Then /^I should see all promoted core field config answers$/ do
  html_source = @browser.get_html_source
  @promoted_core_fields ||= CoreField.all(:conditions => ['event_type = ? AND fb_accessible = ? AND disease_specific = ?', @promoted_event.type.underscore, true, false])
  @promoted_core_fields.each do |core_field|
    raise "Could not find before answer for #{core_field.key}" if html_source.include?("#{core_field.key} before answer") == false
    raise "Could not find after answer for #{core_field.key}" if html_source.include?("#{core_field.key} after answer") == false
  end
end

Given /^I don\'t see any of the promoted core follow up questions$/ do
  html_source = @browser.get_html_source
  @promoted_core_fields ||= CoreField.all(:conditions => ['event_type = ? AND can_follow_up = ? AND disease_specific = ?', @promoted_event.type.underscore, true, false])
  @promoted_core_fields.each do |core_field|
    raise "Should not not find #{core_field.key}" if html_source.include?("#{core_field.key} follow up?") == true
  end
end
