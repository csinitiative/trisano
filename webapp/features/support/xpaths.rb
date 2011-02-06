def xpath_to xpath_name
  case xpath_name

  when /the patient's last name/i
    @xml.xpath('/morbidity_event/interested_party/person/last_name')
    
  else
    raise %W{Can't find mapping from "#{xpath_name}" to an xpath.}
  end
end
