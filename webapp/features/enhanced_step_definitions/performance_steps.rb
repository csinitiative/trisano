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

Given /^I start benchmarking$/ do
  @beginning_time = Time.now
end

Given /^I stop benchmarking of "(.+)"$/ do |title|
  ending_time = Time.now
  outdir = "#{RAILS_ROOT}/log/perf/#{title}"
  `mkdir -p #{outdir}`
  File.open "#{outdir}/benchmark", 'a' do |file|
    file.puts "#{Time.now.to_s(:db)} #{(ending_time - @beginning_time)*1000} milliseconds"
  end
end

Given /^I begin monitoring performance$/ do
  start_monitoring
end

Given /^I end monitoring performance of "(.+)"$/ do |title|
  end_monitoring(title)
end

def start_monitoring
 require 'ruby-prof'
 RubyProf.start 
end

def end_monitoring(title)
  results = RubyProf.stop
  outdir = "#{RAILS_ROOT}/log/perf/#{title}"
  `mkdir -p #{outdir}`
  File.open "#{outdir}/#{Time.now}", 'w' do |file|
    RubyProf::CallTreePrinter.new(results).print(file)
  end
end
