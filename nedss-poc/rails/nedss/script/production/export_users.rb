
def get_input_from_user(prompt, default)
  the_prompt = prompt += " [#{default}] "
  while true
    print prompt
    value = gets.chomp
    value = default if value == ""
    if value == "" # No default supplied
      puts "==> Value may not be blank"
      redo
    end
    return value
  end
end

def get_setup_data
  @postgres_nedss_db = get_input_from_user("Enter the name of the database to export users from", "nedss_prod")
end

def setup_data_is_correct 
  puts 
  puts "The following information has been collected"
  puts 
  puts "PostgreSQL database = #{@postgres_nedss_db}"  

  puts
  repeat = get_input_from_user("Is the above information correct (y/n)?", "y")
  repeat.downcase == "y" ? false : true
end

def export_users
  user_file_name = "users.sql"
  
  puts "exporting users"  
  shell_script_output = `pg_dump -a -t users -t roles -t privileges -t privileges_roles #{@postgres_nedss_db} > #{user_file_name}`
  puts shell_script_output
  
  if File.file? user_file_name   
    puts user_file_name + " created. SUCCESS"
  else
    puts user_file_name + " not found. FAILURE"
  end
end

puts ""
puts "* This script will export users from NEDSS. It has been tested with R1 and R2."
puts ""
server_machine = get_input_from_user "Are you ready to proceed (y/n)?", "y"
exit if server_machine.downcase == "n"

while true
  get_setup_data
  if setup_data_is_correct
    puts "\n==> Repeating\n\n"
    redo
  end
  break
end

exit unless export_users
