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
unless ENV['WATCHR']
  SUCCESS = 0
  FAILURE = 1
  PENDING = 2
end
ENV['RSPEC_COLOR'] = "1"
ENV['WATCHR'] = "1"

@interrupted = false
@ignore_hup = false
@state = SUCCESS

def state(message)
  if message.match(/[1-9][0-9]* (failures?|errors?)/)
    FAILURE
  elsif message.match(/[1-9][0-9]* pending/)
    PENDING
  else
    SUCCESS
  end
end

def growl(message)
  growlnotify = `which growlnotify`.chomp
  unless growlnotify.match(/^\s*$/)
    title = "Watchr Test Results"
    image = case(@state)
      when FAILURE then File.dirname(__FILE__) + "/images/failed.png"
      when PENDING then File.dirname(__FILE__) + "/images/pending.png"
      else File.dirname(__FILE__) + "/images/passed.png"
    end
    options = "-w -n Watchr --image '#{File.expand_path(image)}' -m '#{message}' '#{title}'"
    system %(#{growlnotify} #{options} &)
  end
end

def run(cmd, output=true)
  puts(cmd) if output
  result = ''
  IO.popen(cmd) do |io|
    until io.eof?
      result << io.getc
      print result[-1,1]
      $stdout.flush
    end
  end
  @state = state(result)
  result
end

def cmd_for_files(*files)
  %Q(ruby -Ispec -- #{files.join(' ')} --backtrace)
end

def run_spec_files(*files)
  files.reject! { |file| !File.exists?(file) }
  return if files.empty?
  system('clear')
  result = run cmd_for_files(*files)
  growl result.split("\n").last.gsub(/\[\d+m/, '') rescue nil
end

def run_all_specs
  system('clear')
  puts 'Running all specs...'
  result = run cmd_for_files(Dir['spec/**/*_spec.rb']), false
  growl result.split("\n").last.gsub(/\[\d+m/, '') rescue nil
end

watch('spec/.*/.*_spec\.rb')  { |m| run_spec_files m[0] }
watch('^app/(.*)\.rb')        { |m| run_spec_files "spec/#{m[1]}_spec.rb" }
watch('^lib/(.*)\.rb')        { |m| run_spec_files "spec/lib/#{m[1]}_spec.rb" }

# Ctrl-\
Signal.trap 'QUIT' do
  run_all_specs
end

# Ctrl-C
Signal.trap 'INT' do
  if @interrupted then
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1.5
    @interrupted = false
    reload
  end
end

system 'clear'
