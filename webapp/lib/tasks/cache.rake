namespace :cache do
    task :warm, :host, :limit, :needs => :environment do |task, args|
      require "open3"
      require 'console_app'
      require 'benchmark'
      include ActionController::UrlWriter

      default_url_options[:host] = args[:host] || raise("Must supply host as first argument")
      default_url_options[:protocol] = "https"

      limit = args[:limit].to_i || 1000

      begin

      super_user = User.find_or_create_by_uid_and_user_name("system-super", "system-super")
      super_role = Role.find_or_create_by_role_name("system-super")
      super_role.privileges = Privilege.all
      Place.jurisdictions.each do |jurisdiction|
        RoleMembership.create(:jurisdiction => jurisdiction.entity, :user => super_user, :role => super_role)
      end
       


      api_key = super_user.single_access_token 

      raise "No API key found" if api_key.empty?
      
      current_events = MorbidityEvent.find(:all, :order => "updated_at DESC", :limit => limit)

      current_events.each do |event|
        request_url url_for(:controller => "morbidity_events", :action => "show", :id => event, :api_key => api_key, :only_path => false)
        request_url url_for(:controller => "morbidity_events", :action => "edit", :id => event, :api_key => api_key, :only_path => false)
      end

      super_user.destroy unless super_user.nil?
      super_role.destroy unless super_role.nil?

      rescue Exception => e
        puts e.message
        super_user.destroy unless super_user.nil?
        super_role.destroy unless super_role.nil?
      end
      
    end
end

def request_url(url)
  `wget #{url} --max-redirect=0 --no-check-certificate 2>&1`
  puts "ERROR retrieving #{url}" if $?.exitstatus != 0
end

def ask message
  print message
  STDIN.gets.chomp
end

def execute_with_benchmark
  bench = Benchmark.ms do
    yield
  end
  time_in_seconds = bench.to_i / 1000

  if time_in_seconds > 60
    puts "Warning, page load longer than 60 seconds!"
  end
  puts "  --> approx #{time_in_seconds} seconds"
end
