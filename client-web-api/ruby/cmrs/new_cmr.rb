#!/usr/bin/env ruby

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'trisano-web-api-cmr.rb'

trisano = TriSanoWebApiCmr.new
options = trisano.parse_args(ARGV)

page = trisano.get("/cmrs/new")
form = page.form('new_morbidity_event')
form = trisano.populate_form(form)
result = trisano.submit(form, form['commit']) 

errors = result.search(".//div[@class = 'errorExplanation']")
errors.each { |e|
  error = e.search(".//li")
  error.each { |detail|
    raise detail.text.strip
    exit
  }
}

exit 0
