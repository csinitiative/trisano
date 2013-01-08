# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
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
      raise %{#{shutdown_script}: not found} unless File.file? shutdown_script
      stop_out_and_err = %x[#{shutdown_script}  2>&1]
      ok = stop_out_and_err !~ /Connection refused/
      puts stop_out_and_err
      yield ok if block_given?
      ok
    end

    def undeploy application
      war_name = webapp_dir "#{application}.war"
      File.delete war_name if File.file? war_name
      FileUtils.remove_dir webapp_dir(application) if File.directory? webapp_dir(application)
    end
  end
end
