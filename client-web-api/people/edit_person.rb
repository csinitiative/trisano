#!/usr/bin/env ruby

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'trisano-web-api-person.rb'

trisano = TriSanoWebApiPerson.new
options = trisano.parse_args(ARGV, {:show_id => true})
if options.person_id.nil?
  warn 'Required switch "--id" is missing'
  exit 1
end

page = trisano.get("/people/#{options.person_id}/edit")
form = page.form('edit_person_entity')
form = trisano.populate_form(form)
result = trisano.submit(form, form['commit']) 

errors = result.search(".//div[@class = 'errorExplanation']")
errors.each { |e|
  error = e.search(".//ul")
  error.each { |detail|
    raise detail.text.strip
  }
}

exit 0
