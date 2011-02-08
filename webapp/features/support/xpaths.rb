def xpath_to xpath_name
  case xpath_name

  when /the patient's last name/i
    '/morbidity-event/interested-party-attributes/person-entity-attributes/person-attributes/last-name'
    
  else
    raise %W{Can't find mapping from "#{xpath_name}" to an xpath.}
  end
end
