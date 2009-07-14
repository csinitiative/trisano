#!/usr/bin/env ruby

$LOAD_PATH << './lib'
require 'trisano-web-api.rb'

trisano = TriSanoWebApi.new

# this is just a test.  class names should identify the data we want more precisely.
page = trisano.get('/users').search(".//td[@class='forminformation']/div[@class='tools']/text()[normalize-space(.)]")

page.each { |u|
  puts u.text.strip
}
