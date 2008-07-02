require 'yaml'
require 'fileutils'

WEB_APP_DIR = './WEB-INF/config'

def get_setup_data
  config = YAML::load_file "./config.yml"
    
  @host = config['host']
  @port = config['port']
  @database = config['database']
  @nedss_user = config['nedss_uname']
  @nedss_user_pwd = config['nedss_user_passwd']
  
end

def setup_data_is_correct 
  puts 
  puts "The following information has been collected"
  puts 
  puts "PostgreSQL host server = #{@host}"
  puts "PostgreSQL TCP listen port = #{@port}"
  puts "Database name = #{@database}"
  puts "NEDSS username = #{@nedss_user}"
  puts "NEDSS user's password = #{@nedss_user_pwd}"

  puts
  proceed = get_input_from_user("Is the above information correct (y/n)?", "y")
  puts "Please update the config.yml with the proper settings and run the script again." if proceed.downcase == "n"
  exit if proceed.downcase == "n"
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

def create_web_app_dir  
  if !File.directory? WEB_APP_DIR
    puts "adding directory tree #{WEB_APP_DIR}"
    FileUtils.mkdir_p(WEB_APP_DIR)
  end
end

def create_web_xml
  puts "creating web.xml"
  
  # create dir structure 
  # save .yml with settings from config.yml to database.yml
  # creating the .war  
  
  db_config = { 'production' => 
      { 'adapter' => 'postgresql', 
      'encoding' => 'unicode', 
      'database' => @database, 
      'username' => @nedss_user, 
      'password' => @nedss_user_pwd,
      'host' => @host, 
      'port' => @port
    }      
  }
  
  File.open(WEB_APP_DIR + "/database.yml", "w") {|file| file.puts(db_config.to_yaml) }
end

def create_war_file
  puts "adding web.xml to nedss.war"
  system("jar uf nedss.war #{WEB_APP_DIR}/database.yml")
end

def create_war
  create_web_app_dir
  create_web_xml
  create_war_file  
end

puts ""
puts "* This script will create a .war file with the configured database settings. It has been tested with R1 and R2."
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

exit unless create_war
