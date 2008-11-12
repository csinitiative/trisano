xml.Table {
  for e in @events_to_export
    event = Event.find(e.id)
    xml.ComdisRecord {
      xml.RecordID(event.record_number)
      xml.UpdateFlag(%w( C P S ).include?(event.udoh_case_status.the_code) ? 0 : 1)
      xml.CaseCount(1)
      xml.Event(event.disease.disease.cdc_code)

      onset_date = event.disease.disease_onset_date
      onset_date = onset_date ? onset_date.strftime("%m/%d/%Y") : onset_date
      xml.OnsetDate(onset_date)

      diagnosis_date = event.disease.date_diagnosed
      diagnosis_date = diagnosis_date ? diagnosis_date.strftime("%m/%d/%Y") : diagnosis_date
      xml.DiagnosisDate(diagnosis_date)

      lab_result_date = event.lab_results.collect { |lab_result| lab_result.lab_test_date}.compact.uniq.sort.first
      lab_result_date = lab_result_date ? lab_result_date.strftime("%m/%d/%Y") : lab_result_date
      xml.LabTestDate(lab_result_date)

      reported_date = event.first_reported_PH_date ? event.first_reported_PH_date.strftime("%m/%d/%Y") : event.first_reported_PH_date
      xml.ReportedDate(reported_date)

      addresses = event.patient.primary_entity.address_entities_locations
      address = unless addresses.empty? then addresses.last.location.addresses.last else nil end

      zip_code = address ? address.postal_code : address
      xml.ZipCode(zip_code[0..4])
      
      xml.Age(event.age_info.in_years)

      xml.InvestigationHealthDistrict(get_ibis_health_district(event.primary_jurisdiction))

      if address && address.county && address.county.jurisdiction
        xml.ResidenceHealthDistrict(get_ibis_health_district(address.county.jurisdiction))
      else
        xml.ResidenceHealthDistrict(99)
      end

      xml.Ethnic(get_ibis_ethnicity(event.active_patient.primary_entity.person.ethnicity))
      xml.Race(get_ibis_race(event.patient.primary_entity.races))
      xml.Sex(get_ibis_sex(event.active_patient.primary_entity.person.birth_gender))
      xml.Status(get_ibis_status(event.udoh_case_status))

      xml.Year(event.record_number[0..3])
    }
  end
}
