require 'fileutils'
require File.expand_path(File.dirname(__FILE__) + '/array_extension')
Array.send :include, ArrayExtension

class TriSanoMultiProcessSpecRunner

  def initialize(max_concurrent_processes = 10, reports_prefix = "Default")
    @max_concurrent_processes = max_concurrent_processes
    @reports_prefix = reports_prefix
    puts "Initializing TriSanoMultiProcessSpecRunner with " + @max_concurrent_processes.to_s 
          + " max concurrent processes and reports prefix #{@reports_prefix}"
  end
  
  def run(spec_files)
    concurrent_processes = [ @max_concurrent_processes, spec_files.size ].min
    spec_files_by_process = spec_files / concurrent_processes
    concurrent_processes.times do |i|
      cmd  = "spec #{options(i)} #{spec_files_by_process[i].join(' ')}"
      puts "Launching #{cmd}"
      exec(cmd) if fork == nil
    end
    success = true
    concurrent_processes.times do |i|
      pid, status = Process.wait2
      puts "Test process ##{i} with pid #{pid} completed with #{status}"
      success &&= status.exitstatus.zero?
    end
    puts "Completed testing."
    
    puts "moving results to /data/csi/trisano/test-results/UAT/latest"
    FileUtils.mv("#{screenshot_dir}/Selenium-Build-Report-0.html", "/data/csi/trisano/test-results/UAT/latest/#{@reports_prefix}-set-0.html")
    FileUtils.mv("#{screenshot_dir}/Selenium-Build-Report-1.html", "/data/csi/trisano/test-results/UAT/latest/#{@reports_prefix}-set-1.html")
    puts "see results at http://results.csi.osuosl.org/#{report_file_name}"
    
    # in order to enable N runs (split up # of tests and restart grid), could set an env variable or something and check at the end
    raise "Build failed" unless success
  end

  def compile_report
    script = File.expand_path(File.dirname(__FILE__) + "/aggregate_reports.rb")
    reports = Dir[screenshot_dir + "/Selenium-Build-Report-*.html"].collect {|report| %{"#{report}"} }.join(' ')
    t = Time.now
    tformated = t.strftime("%m-%d-%Y-%I%M%p")
    report_file_name = "#{tformated}-#{@reports_prefix}-Aggregated-Selenium-Report.html"
    command = %{ruby "#{script}" #{reports} > "#{screenshot_dir}/#{report_file_name}"}   
    puts sh
    sh command
    #puts "moving results to /data/csi/trisano/test-results"
    #FileUtils.mv("#{screenshot_dir}/#{report_file_name}", '/data/csi/trisano/test-results')
    #puts "see results at http://results.csi.osuosl.org/#{report_file_name}"
  end
  
  protected
 
  def options(process_number)
    [ "--require './lib/selenium_grid/screenshot_formatter'",
      "--format='Spec::ScreenshotFormatter:#{screenshot_dir}/Selenium-Build-Report-#{process_number}.html'", 
      "--backtrace" 
    ].join(" ")
  end
  
  def screenshot_dir
    './selenium_reports'
  end
    
end
