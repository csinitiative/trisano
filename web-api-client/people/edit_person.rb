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
  edit_string = ''

  opts = OptionParser.new do |opts|
    opts.banner = "Usage: #{__FILE__} [options]"

    opts.separator ""
    opts.separator "Edit options:"

    opts.on("-i MANDATORY", "--id MANDATORY",
            "Person ID.") do |i|
      options.person_id = i
      edit_string += "id=#{i}&"
    end

    opts.on("-f", "--first_name NAME",
            "Person's first name.") do |fn|
      options.first_name = fn
      edit_string += "first_name=#{fn}&"
    end

    opts.on("-f", "--first_name NAME",
            "Person's first name.") do |fn|
      options.first_name = fn
      edit_string += "first_name=#{fn}&"
    end

    opts.on("-m", "--middle_name NAME",
            "Person's middle name.") do |mn|
      options.middle_name = mn
      edit_string += "middle_name=#{mn}&"
    end

    opts.on("-l", "--last_name NAME",
            "Person's last name.") do |ln|
      options.last_name = ln
      edit_string += "last_name=#{ln}&"
    end

    opts.on("-b", "--birth_date DATE",
            "Person's birth date.  Most date formats work, including YYYY-MM-DD.") do |bd|
      options.birth_date = bd
      edit_string += "birth_date=#{bd}&"
    end
  end

  opts.parse!(args)
  edit_string
end  # parse()

@trisano = TriSanoWebApi.new
@query_string = parse(ARGV)
@page = @trisano.get("/people?#{@query_string}").search(".//span[@class='data_person'][span[starts-with(@class, 'data_')]]")

@page.each { |person|
  elements = person.search(".//span[starts-with(@class, 'data_')][not(*)]")
  elements.each { |element|
    name = element.attribute('class').value
    value = element.text
    puts "#{name}: #{value}"
  }
  puts ""
}

# login to the account
page = @trisano.get("/people/#{@options.id}/edit")
#login_form = page.forms.with.name("frmLogin").first
#login_form.txtUserID = '<UNAME>'
#login_form.password = '<PWD>'
#page = @trisano.submit(login_form, login_form.buttons.first)

# click on the download button
#puts "Download"
#dl_link = page.links.with.text(/WAMU FREE CHECKING/)
#page = agent.click(dl_link)
#
#line_items = []

trs = (page/"table#_ctl0_depositTransactionsGrid/tr")
#trs.shift
trs.each do |tr|
  tds = (tr/:td)

  dtd = tds[1].inner_html
  js_call = dtd.match(/showDDATransactionDetails\('(.*)'\);/)[1]
  js_fields = js_call.split("','")

  item = {}
  item['type'] = js_fields[1]
  item['descr'] = js_fields[3]
  item['amount'] = js_fields[4]
  item['tranid'] = js_fields[6]
  # if !tranid = ovedraft charge / bank fee

  item['date'] = tds[0].inner_html
  item['debit'] = tds[3].inner_html
  item['credit'] = tds[4].inner_html
  item['balance'] = tds[5].inner_html

  line_items << item
end
