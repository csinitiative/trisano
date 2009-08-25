#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'

def submit(form)
  begin
    result = form.submit
  rescue WWW::Mechanize::ResponseCodeError => response_error
    local_errors = []
    errors = response_error.page.search(".//div[@class = 'errorExplanation']")
    errors.each { |e|
      e.search(".//li").each { |detail|
        local_errors << detail.text.strip
      }
    }
    e = StagedMessageException.new
    e.errors = local_errors
    raise e
  end
end

class StagedMessageException < RuntimeError
  @errors = []

  def errors
    @errors
  end

  def errors=(e)
    @errors = e
  end
end

hl7_message_good = <<HL7_MSG_GOOD
MSH|^~\&|TRISANO|TRISANO LABS^46D0523979^CLIA|NYDOH|NY|200903261645||ORU^R01|200903261645128667|P|2.3.1|1\rPID|1||17744418^^^^MR||JONES^JOHN^^^^^L||19840810|M||U^Unknown^HL70005|1007 FLATBUSH AVE^^BROOKLYN^NY^11234^^M||^^PH^^^718^1234567|||||||||U^Unknown^HL70189\rOBR|1||09078102377|13954-3^Hepatitis Be Antigen^LN|||200903191011|||||||200903191011|BLOOD|^ROSENKOETTER^YUKI^K||||||200903191011|||F||||||9^Unknown\rOBX|1|ST|13954-3^Hepatitis Be Antigen^LN|1|Positive|Metric Ton|Negative||||F|||200903210007\r
HL7_MSG_GOOD

hl7_message_bad = <<HL7_MSG_BAD  # No LOINC code
MSH|^~\&|TRISANO|TRISANO LABS^46D0523979^CLIA|NYDOH|NY|200903261645||ORU^R01|200903261645128667|P|2.3.1|1\rPID|1||17744418^^^^MR||JONES^JOHN^^^^^L||19840810|M||U^Unknown^HL70005|1007 FLATBUSH AVE^^BROOKLYN^NY^11234^^M||^^PH^^^718^1234567|||||||||U^Unknown^HL70189\rOBR|1||09078102377|13954-3^Hepatitis Be Antigen^LN|||200903191011|||||||200903191011|BLOOD|^ROSENKOETTER^YUKI^K||||||200903191011|||F||||||9^Unknown\rOBX|1|ST|^Hepatitis Be Antigen^LN|1|Positive|Metric Ton|Negative||||F|||200903210007\r
HL7_MSG_BAD

agent = WWW::Mechanize.new

# Goto TriSano home page.  This is the only URL the client should be externally aware of
base_url = ENV['TRISANO_BASE_URL'] || raise('Missing TRISANO_BASE_URL environment variable')
home_page = agent.get(base_url)

# Goto the "staged messages" page pointed to by the link with a 'rel' attribute of: http://trisano.org/relation/staged_messages
# That attribute name will never change and is formally part of the API.
message_page = agent.get(base_url + home_page.at("//a[@rel='http://trisano.org/relation/staged_messages']")['href'])

# Goto the "new staged message" page by following the link with the 'rel' attribute: http://trisano.org/relation/staged_messages_new
# That attribute name will never change and is formally part of the API.
new_message_page = agent.get(base_url + new_staged_messages_link = message_page.at("//a[@rel='http://trisano.org/relation/staged_messages_new']")['href'])

# Find the form with the ID 'new_staged_message'. This form ID will never change and is formally part of the API.
# Note, form names and field names are subject to change.  Always work with IDs.
form_name = new_message_page.at("form#new_staged_message")['name']
hl7_form = new_message_page.form(form_name)

# Populate the field with the ID 'staged_message_hl7_message' with an HL7 message.  This field name will never change and is formally part of the API.
field_name = new_message_page.at("form#new_staged_message textarea#staged_message_hl7_message")['name']
hl7_form[field_name] = hl7_message_good

# Send form to server
begin
  submit(hl7_form)
rescue StagedMessageException => e
  e.errors.each {|e| puts e}
end

# No need to repeat all the find steps to send another message
hl7_form[field_name] = hl7_message_bad
begin
  submit(hl7_form)
rescue StagedMessageException => e
  e.errors.each {|e| puts e}
end

exit 0
