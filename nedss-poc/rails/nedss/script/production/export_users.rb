require 'yaml'
require 'fileutils'

def get_setup_data
  config = YAML::load_file "./config.yml"
    
  @postgres_dir = config['postgres_dir']
  @host = config['host']
  @port = config['port']
  @username = config['priv_uname']
  @password = config['priv_passwd']
  @database = config['database']
  @nedss_user = config['nedss_uname']
  @nedss_user_pwd = config['nedss_user_passwd']

  @pgdump = @postgres_dir + "/pg_dump"
  ENV["PGPASSWORD"] = @password
  
end

def setup_data_is_correct 
  puts 
  puts "The following information has been collected"
  puts 
  puts "PostgreSQL client location = #{@postgres_dir}"
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
  
  dump_dir = "./db-dump"
  if !File.directory? dump_dir
    puts "adding directory #{dump_dir}"
    FileUtils.mkdir_p(dump_dir)
  end  
  
  t = Time.now
  full_dump_file = "full_dump_-" + t.strftime("%m-%d-%Y-%I%M%p") + ".sql"
  system("#{@pgdump} -U #{@username} -h #{@host} -p #{@port} #{@database} > #{dump_dir}/#{full_dump_file}")
  system("#{@pgdump} -a -t privileges -U #{@username} -h #{@host} -p #{@port} #{@database} > #{dump_dir}/priv.sql")
  system("#{@pgdump} -a -t roles -U #{@username} -h #{@host} -p #{@port} #{@database} > #{dump_dir}/roles.sql")
  system("#{@pgdump} -a -t users -U #{@username} -h #{@host} -p #{@port} #{@database} > #{dump_dir}/users.sql")
  system("#{@pgdump} -a -t entitlements -U #{@username} -h #{@host} -p #{@port} #{@database} > #{dump_dir}/entitlements.sql")
  system("#{@pgdump} -a -t privileges_roles -U #{@username} -h #{@host} -p #{@port} #{@database} > #{dump_dir}/privileges_roles.sql")
  system("#{@pgdump} -a -t role_memberships -U #{@username} -h #{@host} -p #{@port} #{@database} > #{dump_dir}/role_memberships.sql")
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
