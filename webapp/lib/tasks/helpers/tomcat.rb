require 'ftools'

module Tasks::Helpers

  class Tomcat
    attr_reader :timeout

    def initialize options={}
      @timeout = (options[:timeout] or 30).to_i
      @home = File.expand_path(options[:tomcat_home] || ENV['TOMCAT_HOME'] || '')
    end

    def home file_name = ''
      File.expand_path file_name, @home
    end

    def startup_script
      bin 'startup.sh'
    end

    def shutdown_script
      bin 'shutdown.sh'
    end

    def bin script=''
      script = File.join 'bin', script
      File.expand_path script, home
    end

    def webapp_dir file_name=''
      File.expand_path file_name, home('webapp')
    end

    def start_server
      sh startup_script
    end

    def stop_server
      stop_out_and_err = %x[#{shutdown_script}  2>&1]
      ok = stop_out_and_err !~ /Connection refused/
      yield ok if block_given?
      ok
    ensure
      puts stop_out_and_err
    end

    def undeploy application
      war_name = webapp_dir "#{application}.war"
      File.delete war_name if File.file? war_name
      FileUtils.remove_dir webapp_dir(application) if File.directory? webapp_dir(application)
    end
  end
end
