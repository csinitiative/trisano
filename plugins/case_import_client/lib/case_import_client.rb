class CaseImportClient
  class << self
    include PostgresFu
  end

  SQL = <<-SQL
     SELECT
       e.id,
       e.workflow_state AS investigation_status,
       e."MMWR_year" as mmwr_year,
       e."MMWR_week" as mmwr_week,
       e.record_number,
       e.age_at_onset,
       to_char(e."first_reported_PH_date", 'YYYY-MM-DD"T"00:00:00') as first_reported_date,
       to_char(e.created_at, 'YYYY-MM-DD"T"HH:MI:SS') as created_date,
       state_case_status.the_code AS state_case_status_code,
       to_char(disease_events.disease_onset_date, 'YYYY-MM-DD"T"00:00:00') as disease_onset_date,
       age_type_codes.the_code AS age_at_onset_type,
       a.state_id,
       a.county_id,
       p.ethnicity_id,
       p.race_id,
       avr_groups.disease_name,
       praces.races,
       sex_conversions.value_to AS sex,
       jurisdiction.short_name jurisdiction_name,
       addresses.postal_code As zip,
       addresses.city,
       county_conversions.value_to as county,
       ethnic_conversions.value_to as ethnicity,
       outbreak_conversions.value_to as outbreak_name,
       case_status_conversions.value_to as state_case_status_value,
       patterns.text_answers,
       patterns.value_answers,
       patterns.questions
      FROM events e
      INNER JOIN participations ip ON (ip.event_id = e.id AND ip.type='InterestedParty')
      INNER JOIN people p ON p.entity_id = ip.primary_entity_id
      INNER JOIN addresses a ON (a.event_id = e.id)
      INNER JOIN disease_events ON e.id = disease_events.event_id
      INNER JOIN (
        SELECT
        d.disease_name,
        de.event_id
        FROM disease_events de
        INNER JOIN diseases d on de.disease_id = d.id
        LEFT JOIN avr_groups_diseases avr on avr.disease_id = d.id
        LEFT JOIN avr_groups ag on ag.id = avr.avr_group_id
        WHERE ag.name = 'STD Data'
      ) avr_groups ON e.id = avr_groups.event_id
      LEFT JOIN
      (
        SELECT
        j.event_id,
        places.short_name
        FROM participations j
        LEFT JOIN entities on j.secondary_entity_id = entities.id
        LEFT JOIN places on entities.id = places.entity_id
        WHERE j.type='Jurisdiction'
      ) jurisdiction ON jurisdiction.event_id = e.id
      LEFT JOIN external_codes age_type_codes ON e.age_type_id = age_type_codes.id
      LEFT JOIN external_codes sex_codes ON p.birth_gender_id = sex_codes.id
      LEFT JOIN
      (
        SELECT z.value_from, z.value_to FROM export_columns sex_columns
        JOIN export_conversion_values z ON sex_columns.id = z.export_column_id
        WHERE sex_columns.export_column_name='SEX'
          AND sex_columns.type_data='CORE'
          AND export_disease_group_id IS NULL
      ) sex_conversions ON sex_codes.the_code = sex_conversions.value_from
      LEFT JOIN addresses ON e.id = addresses.event_id
      LEFT JOIN external_codes county_codes ON addresses.county_id = county_codes.id
      LEFT JOIN
      (
        SELECT value_from, value_to FROM export_columns county_columns
        JOIN export_conversion_values county_conv ON county_columns.id = county_conv.export_column_id
        WHERE county_columns.export_column_name='COUNTY'
          AND county_columns.type_data='CORE'
          AND export_disease_group_id IS NULL
      ) county_conversions ON county_codes.the_code = county_conversions.value_from
       LEFT JOIN external_codes ethnic_codes ON p.ethnicity_id = ethnic_codes.id
       LEFT JOIN
      (
        SELECT zzz.value_from, zzz.value_to FROM export_columns ethnic_columns
        JOIN export_conversion_values zzz ON ethnic_columns.id = zzz.export_column_id
        WHERE ethnic_columns.export_column_name='ETHNICITY'
          AND ethnic_columns.type_data='CORE'
          AND ethnic_columns.export_disease_group_id IS NULL
      ) ethnic_conversions ON ethnic_codes.the_code = ethnic_conversions.value_from
      LEFT JOIN
      (
        SELECT pr.entity_id, ARRAY_ACCUM(race_conversions.value_to) AS races FROM people pr
        LEFT JOIN people_races ON pr.entity_id = people_races.entity_id
        LEFT JOIN external_codes race_codes ON people_races.race_id = race_codes.id
        LEFT JOIN (
          SELECT zz.value_from, zz.value_to FROM export_columns race_columns
          JOIN export_conversion_values zz ON race_columns.id = zz.export_column_id
          WHERE race_columns.export_column_name='RACE'
           AND race_columns.type_data='CORE' AND race_columns.export_disease_group_id IS NULL
        ) race_conversions ON race_codes.the_code = race_conversions.value_from
        GROUP BY pr.entity_id
      ) praces ON praces.entity_id = p.entity_id
      LEFT JOIN external_codes outbreak_codes ON e.outbreak_associated_id = outbreak_codes.id
      LEFT JOIN
      (
        SELECT value_from, value_to FROM export_columns outbreak_columns
        JOIN export_conversion_values outbreak_conv ON outbreak_columns.id = outbreak_conv.export_column_id
        WHERE outbreak_columns.export_column_name='OUTBREAK'
          AND outbreak_columns.type_data='CORE'
          AND export_disease_group_id IS NULL
      ) outbreak_conversions ON outbreak_codes.the_code = outbreak_conversions.value_from
      LEFT JOIN external_codes state_case_status ON e.state_case_status_id = state_case_status.id
      LEFT JOIN
        (
          SELECT value_from, value_to FROM export_columns case_status_columns
          JOIN export_conversion_values case_status_conv ON case_status_columns.id = case_status_conv.export_column_id
          WHERE case_status_columns.export_column_name='CASESTATUS'
            AND case_status_columns.type_data='CORE'
            AND export_disease_group_id IS NULL
      ) case_status_conversions ON state_case_status.the_code = case_status_conversions.value_from
      LEFT JOIN
      (
        SELECT
         answers.event_id as event_id,
         ARRAY_ACCUM(answers.text_answer) as text_answers,
         ARRAY_ACCUM(v.value_to) as value_answers,
         ARRAY_ACCUM(questions.short_name) as questions
        FROM answers
        LEFT JOIN questions ON answers.question_id = questions.id
        LEFT JOIN export_conversion_values v ON answers.export_conversion_value_id = v.id
        WHERE questions.short_name IN ('CDC_Pattern_1', 'CDC_Pattern_2', 'Othr_St_Pattern_1', 'Othr_St_Pattern_2', 'KS_Pattern_1', 'KS_Pattern_2')
        GROUP BY answers.event_id
      ) patterns ON e.id = patterns.event_id
      WHERE e.deleted_at IS NULL
    SQL

  def self.marc_logger
    @@marc_logger ||= Logger.new("#{TRISANO_LOG_LOCATION}/xsentinel.log", 'daily')
  end

  def self.daily_export
    start_date = Date.yesterday.beginning_of_day
    end_date = Date.today.beginning_of_day
    where_clause = " and e.created_at >= '#{start_date.to_s(:db)}' and e.created_at < '#{end_date.to_s(:db)}'"
    cases = HumanEvent.find_by_sql(SQL + where_clause)
    self.marc_logger.info("#{Time.now} Found #{cases.size} records for export")
    self.marc_logger.info(cases.map(&:inspect).join('\n'))

    cases.each do |c|
      patterns = disease_specific_records(c)
      c.races = self.pg_array(c.races)
      c.write_attribute(:cdc_pattern_1, patterns["CDC_Pattern_1"])
      c.write_attribute(:cdc_pattern_2, patterns["CDC_Pattern_2"])
      c.write_attribute(:ks_pattern_1, patterns["KS_Pattern_1"])
      c.write_attribute(:ks_pattern_2, patterns["KS_Pattern_2"])
      c.write_attribute(:othr_st_pattern_1, patterns["Othr_St_Pattern_1"])
      c.write_attribute(:othr_st_pattern_2, patterns["Othr_St_Pattern_2"])
    end
    cases
  end

  def self.start_import
    start_date = Date.yesterday.beginning_of_day
    end_date = Date.today.beginning_of_day
    self.marc_logger.info("*" * 50)
    self.marc_logger.info("#{Time.now.to_s(:short)} Running X-Sentinel export for #{start_date}-#{end_date}")
    cases = self.daily_export
    if cases.empty?
      msg = "No records to export."
    else
      client = Savon::Client.new do
        wsdl.document = "https://apptrain.dhss.mo.gov/Xsentinel/surveillance/caseimportservice.svc/RS"
        http.headers = {
         "VsDebuggerCausalityData" => "uIDPoybVzgv4BJRAkI5qW2coL7QAAAAAdUasL934UkG0ahs2uDb+sFlsOQTmBBtFpJ4qjCt37vwACQAA"}
      end
      response = client.request "ImportPHCases" do
        soap.input = ["ImportPHCases", { "xmlns" => "http://www.stchome.com/marc/services/CaseImportService" } ]
        soap.element_form_default = :unqualified
        http.headers["SOAPAction"] = '"ImportPHCasesRequest"'
        soap.body do |xml|
          xml.tag! "source", "MOHSIS"
          xml.tag! "phCases", "xmlns:a" => "urn:Stchome:Marc:Wcf:CaseImportService:Data:v1", "xmlns:i" => "http://www.w3.org/2001/XMLSchema-instance" do |list|
            cases.each do |c|
              list.tag! "a:PHCase" do |node|
                node.tag! "a:OriginatingSystemId", "EpiTrax"
                node.tag! "a:ID", Digest::SHA1.hexdigest(c.record_number[-6, 6])
                node.tag! "a:Condition", c.disease_name
                node.tag! "a:EventDate", c.created_date
                node.tag! "a:Travel", nil
                node.tag! "a:Age", c.age_at_onset
                node.tag! "a:AgeType", c.age_at_onset_type
                node.tag! "a:Sex", c.sex
                node.tag! "a:LPHA", c.jurisdiction_name
                node.tag! "a:Zip", c.zip
                node.tag! "a:ConditionStatus", c.state_case_status_code
                node.tag! "a:BTHospitalRegion", nil
                node.tag! "a:CDCEnzymePattern1", c.cdc_pattern_1
                node.tag! "a:CDCEnzymePattern2", c.cdc_pattern_2
                node.tag! "a:CDCEnzymePattern3", nil
                node.tag! "a:CDCID", nil
                node.tag! "a:CDCPattern", nil
                node.tag! "a:City", c.city
                node.tag! "a:Comments", nil
                node.tag! "a:County", c.county
                node.tag! "a:Ethnicity", c.ethnicity
                node.tag! "a:InvestigationStatus", c.investigation_status
                node.tag! "a:Jurisdiction", c.jurisdiction_name
                node.tag! "a:LabReportDate", "1971-01-01T00:00:00"
                node.tag! "a:LabratoryName", nil
                node.tag! "a:MMWRWeek", c.mmwr_week
                node.tag! "a:MMWRYear", c.mmwr_year
                node.tag! "a:OnsetDate", c.disease_onset_date
                node.tag! "a:OrganismName", nil
                node.tag! "a:OrganismSpecies", nil
                node.tag! "a:OtherStatePattern1", c.othr_st_pattern_1
                node.tag! "a:OtherStatePattern2", c.othr_st_pattern_2
                node.tag! "a:OtherStatePattern3", nil
                node.tag! "a:Outbreak", c.outbreak_name
                node.tag! "a:Race", c.races
                node.tag! "a:ReferralDate", c.first_reported_date
                node.tag! "a:Region", nil
                node.tag! "a:Serogroup", nil
                node.tag! "a:Serotype", nil
                node.tag! "a:SpecimenCollectionDate", "1971-01-01T00:00:00"
                node.tag! "a:StateEnzymePattern1", c.ks_pattern_1
                node.tag! "a:StateEnzymePattern2", c.ks_pattern_2
                node.tag! "a:StateEnzymePattern3", nil
                node.tag! "a:StateID", config_option(:cdc_state)
                node.tag! "a:StatePattern", nil
                node.tag! "a:TestName", nil
                node.tag! "a:RiskFactors", nil
              end
            end
          end
        end
        self.marc_logger.info(soap.inspect)
      end
      msg = response.success?  ? "Successfully completed." : "Completed with errors."
      msg = msg + " " + response.inspect
    end
    self.marc_logger.info(msg)
    XSentinelMailer.deliver_daily_export_completed(start_date, cases, msg)
  rescue Savon::SOAP::Fault => fault
    self.marc_logger.error(fault.inspect)
    XSentinelMailer.deliver_daily_export_completed(start_date, cases, fault.inspect)
  rescue => ex
    self.marc_logger.error(ex.inspect)
    XSentinelMailer.deliver_daily_export_completed(start_date, cases, ex.inspect)
  end

  private

  def self.disease_specific_records(c)
    return {} if c.questions.blank?
    answers      = self.pg_array_with_nils(c.text_answers)
    conversions   = self.pg_array_with_nils(c.value_answers)
    questions = self.pg_array_with_nils(c.questions)
    results = {}
    answers.each_with_index do |answer, i|
      results[questions[i]] = answer || conversions[i]
    end
    results
  end
end