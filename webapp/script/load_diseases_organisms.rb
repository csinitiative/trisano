puts "Linking diseases and organisms"
begin
  DiseasesOrganism.load_from_yaml(ARGF.read)
rescue
  $stderr.puts "Linking failed"
  $stderr.puts $!
else
  puts "Successfully linked diseases and organisms"
end
