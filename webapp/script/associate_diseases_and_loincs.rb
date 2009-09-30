puts "Associating loinc codes and diseases"
begin
  LoincCode.associate_diseases_from_csv(ARGF.read)
rescue
  $stderr.puts "Associations failed"
  $stderr.puts $!.message
else
  puts "Disease/Loinc associations completed successfully"
end
