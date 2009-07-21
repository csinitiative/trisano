#!/usr/bin/env ruby

$LOAD_PATH << './lib'
require 'trisano-web-api.rb'

trisano = TriSanoWebApi.new

page = trisano.get('/people').search(".//span[@class='person'][span[@class='last_name' or @class='first_name' or @class='middle_name' or @class='birth_date']]")

page.each { |p|
  first_name = p.search(".//span[@class='first_name']").first.text.strip
  middle_name = p.search(".//span[@class='middle_name']").first.text.strip
  last_name = p.search(".//span[@class='last_name']").first.text.strip
  birth_date = p.search(".//span[@class='birth_date']").first.text.strip
  puts "#{last_name}, #{first_name} #{middle_name}"
  if !birth_date.empty?
    puts "  Birth date: #{birth_date}"
  end
}
