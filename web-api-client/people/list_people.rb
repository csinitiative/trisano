#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'trisano-web-api.rb'

def parse(args)
  options = OpenStruct.new
  options.first_name = ""
  options.middle_name = ""
  options.last_name = ""
  options.birth_date = ""
  query_string = ''

  opts = OptionParser.new do |opts|
    opts.banner = "Usage: #{__FILE__} [options]"

    opts.separator ""
    opts.separator "Search options:"

    opts.on("-f", "--first_name NAME",
            "Person's first name.") do |fn|
      options.first_name = fn
      query_string += "first_name=#{fn}&"
    end

    opts.on("-m", "--middle_name NAME",
            "Person's middle name.") do |mn|
      options.middle_name = mn
      query_string += "middle_name=#{mn}&"
    end

    opts.on("-l", "--last_name NAME",
            "Person's last name.") do |ln|
      options.last_name = ln
      query_string += "last_name=#{ln}&"
    end

    opts.on("-b", "--birth_date DATE",
            "Person's birth date.  Most date formats work, including YYYY-MM-DD.") do |bd|
      options.birth_date = bd
      query_string += "birth_date=#{bd}&"
    end
  end

  opts.parse!(args)
  query_string
end  # parse()

@trisano = TriSanoWebApi.new
@query_string = parse(ARGV)
@page = @trisano.get("/people?#{@query_string}").search(".//div[@class='data_person'][span[starts-with(@class, 'data_')]]")

@page.each { |person|
  elements = person.search(".//span[starts-with(@class, 'data_')][not(*)]")
  elements.each { |element|
    name = element.attribute('class').value
    value = element.text
    puts "#{name}: #{value}"
  }
  puts ""
}

exit 0
