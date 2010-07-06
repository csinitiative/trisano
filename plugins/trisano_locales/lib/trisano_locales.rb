# TrisanoLocales
Dir[File.join(File.dirname(__FILE__), '**', '*.rb')].each do |f|
  require f
end

CoreFieldObserver.class_eval do
  observe(:core_field_translation)
end
