ValidatesTimeliness::Formats.format_tokens.select do |t|
  t['mmm']
end.first['mmm'][1] = '(\w{3,})'
ValidatesTimeliness::Formats.add_formats(:date, 'mmm d, yyyy')
ValidatesTimeliness::Formats.add_formats(:date, 'm-d-yy', :before => 'd-m-yy')
ValidatesTimeliness::Formats.add_formats(:date, 'yyyy-mm-ddThh:nn:sszo')
ValidatesTimeliness::Formats.ambiguous_year_threshold = (Time.now.year % 100) + 1
