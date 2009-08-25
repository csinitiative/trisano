#!/usr/bin/env ruby

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'trisano-web-api.rb'
require 'optparse'

opts = OptionParser.new do |opts|
  script_name = caller.last.split(':').first
  opts.banner = "Usage: #{script_name} [FILE]...\nPost FILE(s) contents or standard input as staged messages to TriSano"
  # There are no switches, just a list of file names or stading.  Like cat.
  opts.on("", "STDIN or list of file names containing linefeed separated HL7 messages")
end

begin
  opts.parse!
rescue OptionParser::InvalidOption => e
  puts e
  puts opts
  exit 1
end

trisano_agent = TriSanoWebApi.new

# Goto TriSano home page.  This is the only URL the client should be externally aware of
home_page = trisano_agent.home

# Goto the "staged messages" page pointed to by the link with a 'rel' attribute of: http://trisano.org/relation/staged_messages
# That attribute name will never change and is formally part of the API.
message_page = trisano_agent.get(home_page.at("//a[@rel='http://trisano.org/relation/staged_messages']")['href'])

# Goto the "new staged message" page by following the link with the 'rel' attribute: http://trisano.org/relation/staged_messages_new
# That attribute name will never change and is formally part of the API.
new_message_page = trisano_agent.get(new_staged_messages_link = message_page.at("//a[@rel='http://trisano.org/relation/staged_messages_new']")['href'])

# Note, form names and field names are subject to change.  Always work with IDs.

# Find the form with the ID 'new_staged_message' and retrieve the 'action' attribute. 
# This form ID will never change and is formally part of the API.
form_action = new_message_page.at("form#new_staged_message")['action']

# find the field with the ID 'staged_message_hl7_message' in the form
# This field ID will never change and is formally part of the API.
field_name = new_message_page.at("form#new_staged_message textarea#staged_message_hl7_message")['name']

# Get HL7 messaged from STDIN or named files
ARGF.readlines.each_with_index do |msg, i|
  j = i + 1
  puts "Processing message #{j}"
  begin
    trisano_agent.post(form_action, {field_name => msg})
  rescue TrisanoWebError => e
    puts "Message number #{j} could not be processed due to the following errors:"
    e.errors.each {|e| puts "\t* #{e}"}
  end
end

exit 0
