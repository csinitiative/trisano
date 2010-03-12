module CsvSpecHelper

  def assert_values_in_result(result_arry, value_hash)
    result = result_arry.collect{ |row| CSV.parse_line(row) }
    value_hash.each do |field, regex|
      index = result[0].index(field.to_s)
      result[1][index].should =~ regex
    end
  end

  def simple_reference
    @reference ||= OpenStruct.new(:code_description => "a code",
                                  :best_name => "A Name",
                                  :disease_name => "A Disease",
                                  :name => "Another Name")
  end

  def csv_mock_disease
    morbidity_question = Factory.build(:question)
    morbidity_question.stubs(:short_name).returns("morb_q")

    morbidity_form = Factory.build(:form)
    morbidity_form.stubs(:exportable_questions).returns([morbidity_question])

    d = Factory.build(:disease)
    d.stubs(:live_forms).with("MorbidityEvent").returns([morbidity_form])
    d.stubs(:live_forms).with("ContactEvent").returns([])
    d.stubs(:live_forms).with("PlaceEvent").returns([])

    d
  end

  def to_arry(string)
    a = []
    string.each { |line| a << line.chomp }
    a
  end

  def lab_header
    %w(lab_record_id
  lab_name
  lab_test_type
  lab_organism
  lab_test_result
  lab_result_value
  lab_units
  lab_reference_range
  lab_test_status
  lab_specimen_source
  lab_collection_date
  lab_test_date
  lab_specimen_sent_to_state).join(",")
  end

  def treatment_header
    %w(treatment_record_id
    treatment_given
    treatment
    treatment_date
    stop_treatment_date).join(",")
  end

  def lead_in(event_type)
    case event_type
    when :morbidity
      "patient"
    when :contact
      "contact"
    when :place
      "place"
    end
  end


  def event_header(event_type)
    header_array = []
    lead_in = lead_in(event_type)
    header_array << "#{lead_in}_event_id"
    header_array << "#{lead_in}_record_number" if event_type != :place

    if event_type != :place
      header_array << "#{lead_in}_last_name"
      header_array << "#{lead_in}_first_name"
      header_array << "#{lead_in}_middle_name"
    else
      header_array << "place_name"
      header_array << "place_type"
      header_array << "place_date_of_exposure"
    end

    header_array << "#{lead_in}_address_street_number"
    header_array << "#{lead_in}_address_street_name"
    header_array << "#{lead_in}_address_unit_number"
    header_array << "#{lead_in}_address_city"
    header_array << "#{lead_in}_address_state"
    header_array << "#{lead_in}_address_county"
    header_array << "#{lead_in}_address_postal_code"

    if event_type != :place
      header_array << "#{lead_in}_birth_date"
      header_array << "#{lead_in}_approximate_age_no_birthdate"
      header_array << "#{lead_in}_age_at_onset_in_years"
    end

    header_array << "#{lead_in}_phone_area_code"
    header_array << "#{lead_in}_phone_phone_number"
    header_array << "#{lead_in}_phone_extension"

    if event_type != :place
      header_array << "#{lead_in}_birth_gender"
      header_array << "#{lead_in}_ethnicity"
      header_array << "#{lead_in}_race_1"
      header_array << "#{lead_in}_race_2"
      header_array << "#{lead_in}_race_3"
      header_array << "#{lead_in}_race_4"
      header_array << "#{lead_in}_race_5"
      header_array << "#{lead_in}_race_6"
      header_array << "#{lead_in}_race_7"
      header_array << "#{lead_in}_language"
    end

    if event_type == :contact
      header_array << "contact_disposition"
      header_array << "contact_type"
    end

    if event_type != :place
      header_array << "#{lead_in}_disease"
      header_array << "#{lead_in}_disease_onset_date"
      header_array << "#{lead_in}_date_diagnosed"
      header_array << "#{lead_in}_diagnostic_facility"
      header_array << "#{lead_in}_hospitalized"
      header_array << "#{lead_in}_hospitalization_facility"
      header_array << "#{lead_in}_hospital_admission_date"
      header_array << "#{lead_in}_hospital_discharge_date"
      header_array << "#{lead_in}_hospital_medical_record_no"
      header_array << "#{lead_in}_died"
      header_array << "#{lead_in}_date_of_death"
      header_array << "#{lead_in}_pregnant"
      header_array << "#{lead_in}_clinician_last_name"
      header_array << "#{lead_in}_clinician_first_name"
      header_array << "#{lead_in}_clinician_middle_name"
      header_array << "#{lead_in}_clinician_phone_area_code"
      header_array << "#{lead_in}_clinician_phone_phone_number"
      header_array << "#{lead_in}_clinician_phone_extension"
      header_array << "#{lead_in}_food_handler"
      header_array << "#{lead_in}_healthcare_worker"
      header_array << "#{lead_in}_group_living"
      header_array << "#{lead_in}_day_care_association"
      header_array << "#{lead_in}_occupation"
      header_array << "#{lead_in}_risk_factors"
      header_array << "#{lead_in}_risk_factors_notes"
      header_array << "#{lead_in}_imported_from"

      if event_type == :morbidity
        header_array << "patient_reporting_agency"
        header_array << "patient_reporter_last_name"
        header_array << "patient_reporter_first_name"
        header_array << "patient_reporter_phone_area_code"
        header_array << "patient_reporter_phone_phone_number"
        header_array << "patient_reporter_phone_extension"
        header_array << "patient_results_reported_to_clinician_date"
        header_array << "patient_first_reported_PH_date"
        header_array << "patient_event_onset_date"
        header_array << "patient_MMWR_week"
        header_array << "patient_MMWR_year"
        header_array << "patient_lhd_case_status"
        header_array << "patient_state_case_status"
        header_array << "patient_outbreak_associated"
        header_array << "patient_outbreak_name"
        header_array << "patient_event_name"
        header_array << "patient_jurisdiction_of_investigation"
        header_array << "patient_jurisdiction_of_residence"
        header_array << "patient_workflow_state"
        header_array << "patient_investigation_started_date"
        header_array << "patient_investigation_completed_lhd_date"
        header_array << "patient_review_completed_by_state_date"
        header_array << "patient_investigator"
        header_array << "patient_sent_to_cdc"
        header_array << "acuity"
        header_array << "other_data_1"
        header_array << "other_data_2"
      end
    end
    header_array << "#{lead_in}_event_created_date"
    header_array << "#{lead_in}_event_last_updated_date"
    header_array.join(",")
  end

  def event_output(event_type, m, options={})
    out = ""
    out << "#{m.id},"
    out << "#{m.record_number},"
    out << "#{@person.last_name},"
    out << "#{@person.first_name},"
    out << "#{@person.middle_name},"
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'

    out << "#{@person.birth_date},"
    out << "#{@person.approximate_age_no_birthday},"
    out << "#{m.age_info.in_years},"
    out << '"",'
    out << '"",'
    out << '"",'

    out << "#{@person.birth_gender.code_description},"
    out << "#{@person.ethnicity.code_description},"
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << "#{@person.primary_language.code_description},"
    if event_type == :contact
      out << "#{@person.disposition.code_description},"
      out << "#{@person.disposition.code_description},"
    end
    out << "#{@disease.disease.disease_name},"
    out << "#{@disease.disease_onset_date},"
    out << "#{@disease.date_diagnosed},"
    out << '"",'
    out << "#{@disease.hospitalized.code_description},"
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << "#{@disease.died.code_description},"
    out << "#{@person.date_of_death},"
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << "#{m.imported_from.code_description},"
    if event_type == :morbidity
      out << '"",'
      out << '"",'
      out << '"",'
      out << '"",'
      out << '"",'
      out << '"",'
      out << "#{m.results_reported_to_clinician_date},"
      out << "#{m.first_reported_PH_date},"
      out << "#{m.event_onset_date},"
      out << "#{m.read_attribute("MMWR_week")},"
      out << "#{m.read_attribute("MMWR_year")},"
      out << "#{m.lhd_case_status.code_description},"
      out << "#{m.state_case_status.code_description},"
      out << "#{m.outbreak_associated.code_description},"
      out << "#{m.outbreak_name},"
      out << "#{m.event_name},"
      out << "#{m.primary_jurisdiction.name},"
      out << '"",'
      out << "#{m.workflow_state},"
      out << "#{m.investigation_started_date},"
      out << "#{m.investigation_completed_LHD_date},"
      out << "#{m.review_completed_by_state_date},"
      out << "#{m.investigator.best_name},"
      out << "#{m.sent_to_cdc},"
      out << "#{m.acuity},"
      out << "#{m.other_data_1},"
      out << "#{m.other_data_2},"
      out << "#{Time.parse(m.created_at).strftime('%Y-%m-%d %H:%M')},"
      out << "#{Time.parse(m.updated_at).strftime('%Y-%m-%d %H:%M')},"

      if options[:disease]
        out << "#{m.answers[0].text_answer}"
      end
    end
  end

  def lab_output
    out = ""
    out << '"",' # @lab_result.id
    out << "#{@lab_result.lab_name},"
    out << "#{@lab_result.test_type.common_name},"
    out << "#{@lab_result.organism.organism_name},"
    out << "#{@lab_result.test_result.code_description},"
    out << "#{@lab_result.result_value},"
    out << "#{@lab_result.units},"
    out << "#{@lab_result.reference_range},"
    out << "#{@lab_result.specimen_source.code_description},"
    out << "#{@lab_result.test_status.code_description},"
    out << "#{@lab_result.collection_date},"
    out << "#{@lab_result.lab_test_date},"
    out << "#{@lab_result.specimen_sent_to_state.code_description}"
  end

  def treatment_output
    out = ""
    out << '"",' # treatment.id
    out << "#{@treatment.treatment_given_yn.code_description},"
    out << "#{@treatment.treatment},"
    out << "#{@treatment.treatment_date},"
    out << "#{@treatment.stop_treatment_date}"
  end

  def csv_mock_event(event_type)

    @person = Factory.build(:person)
    @person.stubs(:last_name).returns("Lastname")
    @person.stubs(:first_name).returns("Firstname")
    @person.stubs(:middle_name).returns("Middlename")
    @person.stubs(:birth_date).returns("2008-01-01")
    @person.stubs(:date_of_death).returns("2008-01-02")
    @person.stubs(:approximate_age_no_birthday).returns(55)
    @person.stubs(:birth_gender).returns(simple_reference)
    @person.stubs(:ethnicity).returns(simple_reference)
    @person.stubs(:primary_language).returns(simple_reference)
    @person.stubs(:disposition).returns(simple_reference)

    entity = Factory.build(:person_entity)
    entity.stubs(:telephones).returns([])
    entity.stubs(:person).returns(@person)
    entity.stubs(:races).returns([])

    @treatment = Factory.build(:participations_treatment)
    @treatment.stubs(:treatment_given_yn).returns(simple_reference)
    @treatment.stubs(:treatment).returns("Antibiotics")
    @treatment.stubs(:treatment_date).returns("2008-02-01")
    @treatment.stubs(:stop_treatment_date).returns("2009-02-01")

    @contact = Factory.build(:participations_contact)
    @contact.stubs(:contact_type).returns(simple_reference)
    @contact.stubs(:disposition).returns(simple_reference)

    patient = Factory.build(:interested_party)
    patient.stubs(:person_entity).returns(entity)
    patient.stubs(:treatments).returns([@treatment])
    patient.stubs(:risk_factor).returns(nil)

    @disease = Factory.build(:disease_event)
    @disease.stubs(:disease).returns(simple_reference)
    @disease.stubs(:disease_onset_date).returns("2008-01-03")
    @disease.stubs(:date_diagnosed).returns("2008-01-04")
    @disease.stubs(:hospitalized).returns(simple_reference)
    @disease.stubs(:died).returns(simple_reference)

    if event_type == :morbidity
      a = Factory.build(:answer, :text_answer => 'morb_q answer')
      a.stubs(:short_name).returns('morb_q')
      m = Factory.build(:morbidity_event)
      m.stubs(:answers).returns([a])
    elsif event_type == :contact
      m = Factory.build(:contact_event)
      m.stubs(:participations_contact).returns(@contact)
    else
      m = Factory.build(:place_event)
    end

    m.stubs(:id).returns(1)
    m.stubs(:address).returns(nil)
    m.stubs(:record_number).returns("20080001")
    m.stubs(:event_onset_date).returns("2008-01-05")
    m.stubs(:read_attribute).with("MMWR_week").returns(1)
    m.stubs(:read_attribute).with("MMWR_year").returns(2008)
    m.stubs(:age_info).returns(OpenStruct.new(:in_years => 30))

    m.stubs(:age_type).returns(simple_reference)
    m.stubs(:imported_from).returns(simple_reference)
    m.stubs(:lhd_case_status).returns(simple_reference)
    m.stubs(:state_case_status).returns(simple_reference)
    m.stubs(:outbreak_associated).returns(simple_reference)
    m.stubs(:outbreak_name).returns("an outbreak")

    m.stubs(:disease_event).returns(@disease)
    m.stubs(:disease_id).returns(nil)
    m.stubs(:event_name).returns("an event")
    m.stubs(:workflow_state).returns("new")
    m.stubs(:investigation_started_date).returns("2008-01-06")
    m.stubs(:investigation_completed_lhd_date).returns("2008-01-07")
    m.stubs(:review_completed_by_state_date).returns("2008-01-08")
    m.stubs(:results_reported_to_clinician_date).returns("2008-01-09")
    m.stubs(:first_reported_PH_date).returns("2008-01-10")
    m.stubs(:investigation_completed_LHD_date).returns("2008-01-11")
    #Mon Jun 29 13:29:58 -0400 2009 should be exported as 2009-06-29 13:29:58
    m.stubs(:created_at).returns("Mon Jun 29 13:29:58 -0400 2009")
    m.stubs(:updated_at).returns("Mon Jun 29 13:29:58 -0400 2009")

    m.stubs(:investigator).returns(simple_reference)
    m.stubs(:sent_to_cdc).returns(true)

    m.stubs(:primary_jurisdiction).returns(simple_reference)
    m.stubs(:interested_party).returns(patient)

    m.stubs(:place_exposures).returns([])
    m.stubs(:safe_call_chain).returns(nil)
    m.stubs(:labs).returns([])
    m.stubs(:hospitalization_facilities).returns([])
    m.stubs(:diagnostic_facilities).returns([])
    m.stubs(:clinicians).returns([])
    m.stubs(:contacts).returns([])
    m.stubs(:acuity).twice.returns(1)
    m.stubs(:other_data_1).returns('First Other Data')
    m.stubs(:other_data_2).returns('Second Other Data')
    m.stubs(:deleted_at).returns(nil)

    @common_test_type = Factory.build(:common_test_type)
    @common_test_type.stubs(:common_name).returns("Biopsy")

    @organism = Factory.build(:organism)
    @organism.stubs(:organism_name).returns("Cooties")

    @lab_result = Factory.build(:lab_result)
    @lab_result.stubs(:lab_name).returns("LabName")
    @lab_result.stubs(:test_type).returns(@common_test_type)
    @lab_result.stubs(:organism).returns(@organism)
    @lab_result.stubs(:test_result).returns(simple_reference)
    @lab_result.stubs(:result_value).returns("100")
    @lab_result.stubs(:units).returns("Gallons")
    @lab_result.stubs(:reference_range).returns("Detected")
    @lab_result.stubs(:specimen_source).returns(simple_reference)
    @lab_result.stubs(:test_status).returns(simple_reference)
    @lab_result.stubs(:collection_date).returns("2008-02-01")
    @lab_result.stubs(:lab_test_date).returns("2008-02-02")
    @lab_result.stubs(:specimen_sent_to_state).returns(simple_reference)
    m.stubs(:lab_results).returns([@lab_result])

    m.stubs(:reload).returns(m)
    m
  end
end
