def get_setup_data
  @postgres_dir = "/usr/bin"
  @host = "localhost"
  @port = 5432
  @username = "mike"
  @password = "password"
  @database = "nedss_prod"
  @nedss_user = "nedss_prod_user"
  @nedss_user_pwd = "password"

  @pgdump = @postgres_dir += "/pg_dump"
  ENV["PGPASSWORD"] = @password
end

def setup_data_is_correct 
  puts 
  puts "The following information has been collected"
  puts 
  puts "PostgreSQL host server = #{@host}"
  puts "PostgreSQL TCP listen port = #{@port}"
  puts "Database name = #{@database}"
  puts "Database privileged username = #{@username}"
  puts "Privileged user's password = #{@password}"
  puts "NEDSS username = #{@nedss_user}"
  puts "NEDSS user's password = #{@nedss_user_pwd}"

  puts
  repeat = get_input_from_user("Is the above information correct (y/n)?", "y")
  repeat.downcase == "y" ? false : true
end

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

def export_users
  # Export tables one at a time - I tried exporting to one file, but ran into foreign key constraints so fell back to this.  
  puts "exporting user related tables"  
  #system("pg_dump -a -t privileges #{@postgres_nedss_db} > priv.sql")
  #system("pg_dump -a -t roles #{@postgres_nedss_db} > roles.sql")
  #system("pg_dump -a -t users #{@postgres_nedss_db} > users.sql")
  #system("pg_dump -a -t entitlements #{@postgres_nedss_db} > entitlements.sql")
  #system("pg_dump -a -t privileges_roles #{@postgres_nedss_db} > privileges_roles.sql")
  #system("pg_dump -a -t role_memberships #{@postgres_nedss_db} > role_memberships.sql")
  
  
  system("#{@pgdump} -U #{@username} -h #{@host} -p #{@port} #{@database} > priv.sql")
  system("#{@pgdump} -U #{@username} -h #{@host} -p #{@port} #{@database} > roles.sql")
  system("#{@pgdump} -U #{@username} -h #{@host} -p #{@port} #{@database} > users.sql")
  system("#{@pgdump} -U #{@username} -h #{@host} -p #{@port} #{@database} > entitlements.sql")
  system("#{@pgdump} -U #{@username} -h #{@host} -p #{@port} #{@database} > privileges_roles.sql")
  system("#{@pgdump} -U #{@username} -h #{@host} -p #{@port} #{@database} > role_memberships.sql")
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
