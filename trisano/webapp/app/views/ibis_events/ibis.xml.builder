xml.Table {
  for event in @events_to_export
    xml.ComdisRecord {
      xml.RecordID(event.record_number)

      if event.deleted_at || ! %w( C P S ).include?(event.state_case_status.the_code)
        update_flag = 1
      else
        update_flag = 0
      end

      xml.UpdateFlag(update_flag)
      if update_flag == 0
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

        address = event.address

        zip_code = address ? address.postal_code : ""
        xml.ZipCode(zip_code[0..4])
        
        xml.Age(event.age_info.in_years)

        if address && address.county && address.county.jurisdiction
          residence_jurisdiction = get_ibis_health_district(address.county.jurisdiction)
        else
          residence_jurisdiction = 99
        end
        investigation_jurisdiction = get_ibis_health_district(event.primary_jurisdiction)
        if investigation_jurisdiction == 99 then investigation_jurisdiction = residence_jurisdiction end

        xml.InvestigationHealthDistrict(investigation_jurisdiction)
        xml.ResidenceHealthDistrict(residence_jurisdiction)

        xml.Ethnic(get_ibis_ethnicity(event.interested_party.person_entity.person.ethnicity))
        xml.Race(get_ibis_race(event.interested_party.person_entity.races))
        xml.Sex(get_ibis_sex(event.interested_party.person_entity.person.birth_gender))
        xml.Status(get_ibis_status(event.state_case_status))

        xml.Year(event.record_number[0..3])
      end
    }
  end
}
