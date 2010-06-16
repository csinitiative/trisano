# Include hook code here
Dir[File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')].each do |f|
  require f
end