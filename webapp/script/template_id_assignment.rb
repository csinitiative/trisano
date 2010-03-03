# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

puts 'h1. Form reference template ID assignment migration'

connection = ActiveRecord::Base.connection

Form.find(:all).each do |form|

  puts "h2. #{form.name}"
  puts "*Form ID: #{form.id}*"
  puts "*Template ID: #{form.template_id}*"

  if form.template_id.nil?
    puts "Not a published version. Status '#{form.status}'"
  else
    puts "This form is a published instance. Status '#{form.status}'"
    puts "Updating form references for this form: Setting template_id to #{form.template_id} where form_id = #{form.id}"
    result = connection.execute("UPDATE form_references SET template_id = #{form.template_id} WHERE form_id = #{form.id};")
    puts "{noformat}"
    p result
    puts "{noformat}"
  end
end
