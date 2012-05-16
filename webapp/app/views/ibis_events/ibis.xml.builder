xml.Table {
  for event in @events_to_export

    xml.ComdisRecord {
      xml.RecordID(event['record_number'])

      update_flag = event['deleted_at'].blank? ? 0 : 1

      xml.UpdateFlag(update_flag)
      if update_flag == 0
        xml.CaseCount(1)
        xml.Event(event['disease_cdc_code'])

        xml.EventOnsetDate(event.export_eventdate)

        onset_date = event['disease_onset_date']
        onset_date = onset_date.blank? ? onset_date : Date.strptime(onset_date, "%Y-%m-%d").strftime("%m/%d/%Y")
        xml.OnsetDate(onset_date)
        
        diagnosis_date = event['disease_event_date_diagnosed']
        diagnosis_date = diagnosis_date.blank? ? diagnosis_date : Date.strptime(diagnosis_date, "%Y-%m-%d").strftime("%m/%d/%Y")
        xml.DiagnosisDate(diagnosis_date)

        lab_result = LabResult.find(
          :first,
          :select => 'collection_date',
          :joins => "JOIN participations p ON lab_results.participation_id = p.id JOIN events e ON p.event_id = e.id",
          :conditions => "e.id = #{event['event_id']}",
          :order => "collection_date"
        )

        if (!lab_result.nil? && !lab_result.collection_date.nil?)
          lab_result_date = lab_result.collection_date.strftime("%m/%d/%Y")
        else
          lab_result_date = ""
        end
        
        xml.LabTestDate(lab_result_date)

        reported_date = event['first_reported_ph_date']
        reported_date = reported_date.blank? ? reported_date : Date.strptime(reported_date, "%Y-%m-%d").strftime("%m/%d/%Y")
        xml.ReportedDate(reported_date)
        
        zip_code = event['address_postal_code'].blank? ? "" : event['address_postal_code'][0..4]
        xml.ZipCode(zip_code)
        
        xml.County get_ibis_county_code(event['address_county_code'])
        xml.Age(AgeInfo.new(event['age_at_onset'], event['age_type_id']).in_years)

        if !event['address_county_code'].blank? && !event['residence_jurisdiction_short_name'].blank?
          residence_jurisdiction = get_ibis_health_district(event['residence_jurisdiction_short_name'])
        else
          residence_jurisdiction = 99
        end

        investigation_jurisdiction = get_ibis_health_district(event['investigation_jurisdiction_short_name'])
        if investigation_jurisdiction == 99 then investigation_jurisdiction = residence_jurisdiction end
        
        xml.InvestigationHealthDistrict(investigation_jurisdiction)
        xml.ResidenceHealthDistrict(residence_jurisdiction)

        xml.Ethnic(get_ibis_ethnicity(event['interested_party_ethnicity_code']))

        race_ids = []
        
        unless event['interested_party_person_entity_id'].blank?
          race_ids = ActiveRecord::Base.connection.select_values("SELECT ec.the_code FROM people_races pr INNER JOIN external_codes ec ON pr.race_id = ec.id WHERE entity_id = #{event.interested_party_person_entity_id}")
        end

        xml.Race(get_ibis_race(race_ids))

        xml.Sex(get_ibis_sex(event['interested_party_sex_code']))
        xml.Status(get_ibis_status(event['event_case_status_code']))
        xml.LocalStatus get_ibis_status(event['event_lhd_case_status'])
        xml.Year(event['record_number'][0..3])
        
        created_date = DateTime.strptime(event['event_created_at'], "%Y-%m-%d %H:%M:%S").strftime("%m/%d/%Y") unless event['event_created_at'].blank?
        xml.EventCreatedDate created_date
      end
    }
  end
}
