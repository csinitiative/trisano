require 'rake/tasklib'

module Tasks::Helpers

  class Tomcat < ::Rake::TaskLib    
    attr_reader :timeout
    attr_reader :home

    def initialize options={}
      @timeout = (options[:timeout] or 30).to_i
      @home = File.expand_path(options[:tomcat_home] || ENV['TOMCAT_HOME'] || '')
      generate_tasks
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

    private

    def generate_tasks
      namespace :tomcat do
        start_task
        stop_task
      end
    end

    def start_task
      if File.file?(startup_script)
        task(:start) { sh startup_script }
      else
        task(:start) { raise %{Can't find '#{startup_script}'. Is $TOMCAT_HOME set correctly?} }
      end
    end

    def stop_task
      if File.file?(shutdown_script)
        task(:stop) do
          stop_server { |ok| sleep timeout if ok }
        end
      else
        task(:stop) { raise %{Can't find '#{shutdown_script}'. Is $TOMCAT_HOME set correctly?} }
      end
    end

    def start_server
      sh startup_script
    end

    def stop_server
      stop_out_and_err = %x[#{shutdown_script}  2>&1]
      ok = stop_out_and_err !~ /Connection refused/
      yield ok
    ensure
      puts stop_out_and_err
    end

  end

end
