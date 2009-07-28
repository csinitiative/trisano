#!/usr/bin/env ruby

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'trisano-web-api-person.rb'

trisano = TriSanoWebApiPerson.new
options = trisano.parse_args(ARGV)

page = trisano.get("/people/new")
form = page.form('new_person_entity')
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
