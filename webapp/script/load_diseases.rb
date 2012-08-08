puts "Loading diseases (script/load_diseases.rb)"
begin
  Disease.load_from_yaml(ARGF.read)
rescue
  $stderr.puts "Loading diseases failed"
  $stderr.puts $!
else
  puts "Successfully loaded diseases\n\n"
end
