def get_setup_data
  @postgres_dir = get_input_from_user("Enter the absolute path to the directory containing the PostgreSQL psql client", "/usr/bin")
  @host = get_input_from_user("Enter the server name on which PostgreSQL is running", "localhost")
  @port = get_input_from_user("Enter the TCP port on which the PostgreSQL database is listening", 5432)
  @username = get_input_from_user("Enter the name of a database user with sufficient privileges to create databases and users", "postgres")
  @password = get_input_from_user("Enter the password of the privileged user", "")
  @database = get_input_from_user("Enter the name of a database to create for NEDSS production use. Must NOT already exist!", "nedss_prod")
  @nedss_user = get_input_from_user("Enter the name of the user that NEDSS will connect to the database as.  Must NOT already exist!", "nedss")
  @nedss_user_pwd = get_input_from_user("Enter the password of the NEDSS user", "")

  @psql = @postgres_dir += "/psql"
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

def create_database
  puts "Creating NEDSS database."
  success = system("#{@psql} -U #{@username} -h #{@host} -p #{@port} postgres -e -c 'CREATE DATABASE #{@database}'")
  if success
    puts "Successfully created database structure for NEDSS."
  else
    puts "Creation of NEDSS database structure failed."
  end
  return success
end

def create_structure
  puts "Creating tables and other such things."
  success = system("#{@psql} -U #{@username} -h #{@host} -p #{@port} #{@database} -e -f nedss_schema.sql")
  if success
    puts "Successfully created database structure for NEDSS."
  else
    puts "Creation of NEDSS database structure failed."
  end
  return success
end

def set_locale
  puts "Setting locale for full text search."
  success = system("#{@psql} -U #{@username} -h #{@host} -p #{@port} #{@database} -e -c \"UPDATE pg_ts_cfg SET LOCALE = current_setting('lc_collate') WHERE ts_name = 'default'\"")
  if success
    puts "Successfully set locale for full text search."
  else
    puts "Setting locale failed."
  end
  return success
end

def create_user
  puts "Creating NEDSS user."
  success = system("#{@psql} -U #{@username} -h #{@host} -p #{@port} #{@database} -c \"CREATE USER #{@nedss_user} ENCRYPTED PASSWORD '#{@nedss_user_pwd}'\"")
  if success
    puts "Successfully created NEDSS user."
  else
    puts "Creation of NEDSS user failed."
  end
  return success
end

def grant_privs
  puts "Granting privileges to NEDSS user."
  success = system("#{@psql} -U #{@username} -h #{@host} -p #{@port} #{@database} -c 'GRANT ALL ON SCHEMA public TO #{@nedss_user}'")
  unless success
    puts "Granting of privileges to NEDSS user failed. Could not install plpgsql language into database."
    return success
  end
  success = system("#{@psql} -U #{@username} -h #{@host} -p #{@port} #{@database} -e -f load_grant_function.sql")
  unless success
    puts "Granting of privileges to NEDSS user failed.  Could not create grant privileges function."
    return success
  end
  success = system("#{@psql} -U #{@username} -h #{@host} -p #{@port} #{@database} -e -c \"SELECT pg_grant('#{@nedss_user}', 'all', '%', 'public')\"")
  if success
    puts "Successfully granted privileges to NEDSS user."
  else
    puts "Granting of privileges to NEDSS user failed."
  end
  return success
end

puts ""
puts "* This script will initialize a PostgreSQL database with everything needed to"
puts "* run NEDSS"
puts "*"
puts "*                  Pre-requisites"
puts "*"
puts "*  - PostgeSQL 8.2 is installed locally or on a network accessible server."
puts "*  - The PostgeSQL 'contrib' package is also installed."
puts "*  - This script is being run on a machine with the psql client installed."
puts "*  - You know the username and password of a Postgres user with sufficient"
puts "*    privileges to create databases and users"
puts "*  - The NEDSS database and user have _NOT_ already been created (this script"
puts "*    will create them)."
puts ""
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

exit unless create_database
exit unless create_structure
exit unless set_locale
exit unless create_user
exit unless grant_privs
