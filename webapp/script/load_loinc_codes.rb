puts "Loading loinc codes (script/load_loinc_codes.rb)"
begin
  LoincCode.load_from_csv(ARGF.read)
rescue
  $stderr.puts "Loading loinc codes failed"
  $stderr.puts $!.message
else
  puts "Successfully loaded loinc codes\n\n"
end
