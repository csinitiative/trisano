#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'trisano-web-api.rb'

def parse(args)
  @options = OpenStruct.new

  opts = OptionParser.new do |opts|
    opts.banner = "Usage: #{__FILE__} [options]"

    opts.separator ""
    opts.separator "Edit options:"

    opts.on("-i", "--id PERSON_ID",
            "Person ID.") do |i|
      @options.person_id = i
    end

    opts.on("-f", "--first_name NAME",
            "Person's first name.") do |fn|
      @options.first_name = fn
    end

    opts.on("-m", "--middle_name NAME",
            "Person's middle name.") do |mn|
      @options.middle_name = mn
    end

    opts.on("-l", "--last_name NAME",
            "Person's last name.") do |ln|
      @options.last_name = ln
    end

    opts.on("-b", "--birth_date DATE",
            "Person's birth date.  Most date formats work, including YYYY-MM-DD.") do |bd|
      @options.birth_date = bd
    end
  end

  opts.parse!(args)
  @options
end  # parse()

def populate_form(form)
  if !@options.first_name.nil?
    form['person_entity[person_attributes][first_name]'] = @options.first_name
  end
  if !@options.middle_name.nil?
    form['person_entity[person_attributes][middle_name]'] = @options.middle_name
  end
  if !@options.last_name.nil?
    form['person_entity[person_attributes][last_name]'] = @options.last_name
  end
  if !@options.birth_date.nil?
    form['person_entity[person_attributes][birth_date]'] = @options.birth_date
  end
  form
end

@trisano = TriSanoWebApi.new
@options = parse(ARGV)
if @options.person_id.nil?
  raise 'Required switch "--id" is missing'
end

@page = @trisano.get("/people/#{@options.person_id}/edit")
@form = @page.form('edit_person_entity')
@form = populate_form(@form)
@result = @trisano.submit(@form, @form['commit']) 

@errors = @result.search(".//div[@class = 'errorExplanation']")
@errors.each { |e|
  error = e.search(".//ul")
  error.each { |detail|
    raise detail.text.strip
  }
}

exit 0
