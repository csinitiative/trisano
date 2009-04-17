#!/usr/bin/env ruby

require 'thread'
require 'optparse'
require 'optparse/time'
require 'ostruct'

class UserAcceptanceTest
  def initialize()  
    @lock = Mutex.new  # For thread safety  
    @options = parse(ARGV)
    @server = @options.server.split(/,\s*/)
    @port = @options.port
    @concurrent = @options.concurrent
    @results = {}
    @total_examples = 0
    @total_fail = 0
    @uats = Dir.glob("spec/uat/#{@options.tests}.rb")
  end  

  def run()
    @threads = []
    @server.each do |s|
      1 .. @concurrent.to_i.times do |c|
        t = Thread.new {
          log = File.new("uat.#{s}-#{c}.#{@port}.out", "w")
          while (path = nextUAT()) do
            cmd  = "spec #{path}"
            puts "Launching #{s}-#{c}:#{@port} => #{cmd}"
            $stdout.flush
            log.write "#{cmd}\n"
            output = `$TOMCAT_HOME/bin/shutdown.sh; $TOMCAT_HOME/bin/startup.sh; export SEL_RC_SERVER=#{s}; export RC_PORT=#{@port}; #{cmd} 2>&1`
            if (output.match(/(\d+) examples?, (\d+) failures?/))
              @lock.synchronize {
                @results[path] = { "examples" => $1.to_i,
                                   "failures" => $2.to_i }
                @total_examples += $1.to_i
                @total_fail += $2.to_i
              }
            end
            log.write(output)
            log.flush
          end
        }
        @threads.push(t)
      end
    end

    # wait for threads to finish
    @threads.each do |t|
      t.join
    end

    printf("%-60s%10s%10s\n", 'Name', 'Examples', 'Failures')
    results.keys.each do |test|
      file = test.sub(/^.*\//, '')
      printf("%-60s%10s%10s\n", file, results[test]['examples'], results[test]['failures'])
    end

    puts ""
    printf("%-60s%10s%10s\n", 'Total', total_examples, total_fail)
  end
  
  private

  def parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.server = "localhost"
    options.port = 4444
    options.tests = '*'
    options.concurrent = 1

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: run_uats.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-s", "--server HOST",
              "Selenium RC host.  Separate multiples with commas.") do |server|
        options.server = server
      end

      opts.on("-p", "--port PORT",
              "Selenium RC tcp port.") do |port|
        options.port = port
      end

      opts.on("-t", "--tests GLOB",
              "GLOB pattern for UATs to be run.") do |tests|
        options.tests = tests
      end

      opts.on("-c", "--concurrent INTEGER",
              "Number of concurrent UATs to run per server.") do |concurrent|
        options.concurrent = concurrent
      end
    end

    opts.parse!(args)
    options
  end  # parse()`

  def nextUAT
    @lock.synchronize {
      @t = @uats.pop
    }
  end

  def options
    @options
  end

  def server
    @server
  end

  def port
    @port
  end

  def results
    @results
  end

  def total_examples
    @total_examples
  end

  def total_fail
    @total_fail
  end
  
end  

uat = UserAcceptanceTest.new()
uat.run()
