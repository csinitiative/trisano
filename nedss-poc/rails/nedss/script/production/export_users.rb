
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
  # Export tables one at a time - I tried exporting to one file, but ran into foreign key constraints so fell back to this.  
  puts "exporting user related tables"  
  system("pg_dump -a -t privileges #{@postgres_nedss_db} > priv.sql")
  system("pg_dump -a -t roles #{@postgres_nedss_db} > roles.sql")
  system("pg_dump -a -t users #{@postgres_nedss_db} > users.sql")
  system("pg_dump -a -t entitlements #{@postgres_nedss_db} > entitlements.sql")
  system("pg_dump -a -t privileges_roles #{@postgres_nedss_db} > privileges_roles.sql")
  system("pg_dump -a -t role_memberships #{@postgres_nedss_db} > role_memberships.sql")
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
