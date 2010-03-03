# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

# For each master copy of a form, displays how many times a short name is in
# use on that form.
#
# Outputs MoinMoin wiki format.

connection = ActiveRecord::Base.connection
master_copies = Form.find_all_by_is_template(true, :order => "name")

master_copies.each do |master_copy|

  sql = "SELECT DISTINCT q.short_name, COUNT(*) AS count FROM questions q "
  sql  << "inner join form_elements fe on q.form_element_id = fe.id "
  sql  << "inner join forms f on fe.form_id = f.id "
  sql  << "where f.id = #{master_copy.id}  "
  sql  << "GROUP BY q.short_name ORDER BY COUNT(*) desc;"

  puts "== #{master_copy.name} =="

  puts "||'''Short Name'''||'''Count'''||"

  connection.select_rows(sql).each do |record|
    puts "||#{record[0]}||#{record[1]}||\n"
  end

end
