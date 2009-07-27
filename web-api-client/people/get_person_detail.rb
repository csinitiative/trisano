#!/usr/bin/env ruby

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'trisano-web-api.rb'

trisano = TriSanoWebApi.new

id = $ARGV[0] || raise('Need person id as argument')

person = trisano.get("/people/#{id}").search(".//div[starts-with(@class, 'data_')]")

elements = person.search(".//span[starts-with(@class, 'data_')][not(*)]")
elements.each { |element|
  name = element.attribute('class').value
  value = element.text
  puts "#{name}: #{value}"
}

exit 0
