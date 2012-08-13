class IbisExport
 class << self
    def exportable_ibis_records(start_date, end_date)
      active_sql = ibis_export_sql do
        <<-WHERE
          events.type = 'MorbidityEvent' AND
          events.deleted_at IS NULL AND
          (
            (events.created_at::date BETWEEN ?::date AND ?::date) OR
            (events.ibis_updated_at BETWEEN ? AND ?)
          )
        WHERE
      end

      deleted_sql = ibis_export_sql do
        <<-WHERE
          events.type = 'MorbidityEvent'
          AND events.sent_to_ibis = true
          AND events.deleted_at::date BETWEEN ?::date AND ?::date
        WHERE
      end

      Event.find_by_sql([active_sql, start_date, end_date, start_date, end_date]) + Event.find_by_sql([deleted_sql, start_date, end_date])
    end

    def reset_ibis_status(events)
      event_ids = events.compact.collect do |record|
        if record.respond_to?(:event_id)
          record.event_id if record.event_id
        else
          record.id if record.id
        end
      end
      Event.update_all('sent_to_ibis=true', ['id IN (?)', event_ids])
    end

    def ibis_export_sql
      sql = <<-SQL
        SELECT
        events.id AS event_id,
        events.imported_from_id AS imported_from_id,
        events."first_reported_PH_date" AS first_reported_ph_date,
        events.age_at_onset AS age_at_onset,
        events.age_type_id AS age_type_id,
        events.created_at AS event_created_at,
        events.record_number AS record_number,
        events.deleted_at AS deleted_at,
        scsid.the_code AS event_case_status_code,
        lcsid.the_code AS event_lhd_case_status,
        diseases.cdc_code AS disease_cdc_code,
        disease_events.disease_onset_date AS disease_onset_date,
        disease_events.date_diagnosed AS disease_event_date_diagnosed,
        addresses.postal_code AS address_postal_code,
        cid.the_code AS address_county_code,
        cjid.short_name AS residence_jurisdiction_short_name,
        jurispl.short_name AS investigation_jurisdiction_short_name,
        intpplent.id AS interested_party_person_entity_id,
        ethid.the_code AS interested_party_ethnicity_code,
        sexid.the_code AS interested_party_sex_code,
        events.event_onset_date AS event_onset_date
    FROM
        events
        LEFT OUTER JOIN disease_events
            ON disease_events.event_id = events.id
        JOIN diseases
            ON diseases.id = disease_events.disease_id
        LEFT OUTER JOIN addresses
            ON addresses.event_id = events.id
        LEFT JOIN external_codes cid
            ON cid.id = addresses.county_id
        LEFT JOIN places cjid
            ON cjid.id = cid.jurisdiction_id
        LEFT JOIN external_codes ifid
            ON ifid.id = events.imported_from_id
        LEFT JOIN external_codes scsid
            ON scsid.id = events.state_case_status_id
        LEFT JOIN external_codes oaid
            ON oaid.id = events.outbreak_associated_id
        LEFT JOIN external_codes lcsid
            ON lcsid.id = events.lhd_case_status_id
        LEFT JOIN external_codes disevhospid
            ON disevhospid.id = disease_events.hospitalized_id
        LEFT JOIN external_codes disevdiedid
            ON disevdiedid.id = disease_events.died_id
        JOIN participations juris
            ON juris.event_id = events.id AND juris.type = 'Jurisdiction'
        JOIN entities jurisent
            ON juris.secondary_entity_id = jurisent.id AND jurisent.entity_type = 'PlaceEntity'
        JOIN places jurispl
            ON jurispl.entity_id = juris.secondary_entity_id
        JOIN participations intpplpart
            ON intpplpart.type = 'InterestedParty' AND intpplpart.event_id = events.id
        JOIN entities intpplent
            ON intpplent.id = intpplpart.primary_entity_id
        JOIN people intppl
            ON intppl.entity_id = intpplpart.primary_entity_id
        LEFT JOIN external_codes ethid
            ON ethid.id = intppl.ethnicity_id
        LEFT JOIN external_codes sexid
            ON sexid.id = intppl.birth_gender_id
        WHERE
      SQL

      sql <<  yield
      sql << "order by events.id;"
    end
 end
end