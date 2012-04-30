namespace :cache do
    task :warm, :protocol, :host_url, :limit, :needs => :environment do |task, args|
      require 'console_app'
      require 'benchmark'
      include ActionController::UrlWriter
     
      default_url_options[:protocol] = args[:protocol] || "http"
      default_url_options[:host] = args[:host_url] || ask("HOST URL? ")
      limit = args[:limit] || ask("Records to cache? ")

      api_key = User.find(:first, :conditions => "single_access_token IS NOT NULL").single_access_token 

      raise "No API key found" if api_key.empty?
      
      current_events = MorbidityEvent.find(:all, :order => "updated_at DESC", :limit => limit)

      current_events.each do |event|
        request_url url_for(:controller => "morbidity_events", :action => "show", :id => event, :api_key => api_key)
        request_url url_for(:controller => "morbidity_events", :action => "edit", :id => event, :api_key => api_key)
      end
      
    end
end

def request_url(url)
  sanitized_url = url.gsub(/api_key=..................../, '')
  puts "loading #{sanitized_url}"
  execute_with_benchmark do
    puts "returned " + app.get(url).to_s
  end
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
