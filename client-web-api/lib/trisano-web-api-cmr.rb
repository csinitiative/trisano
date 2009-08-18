require 'optparse'
require 'ostruct'
require 'trisano-web-api.rb'

class TriSanoWebApiCmr < TriSanoWebApi
  def parse_args(args, options = {})
    @options = OpenStruct.new

    script_name = caller.last.split(':').first
    @opts = OptionParser.new("Usage: #{script_name} [options]", 40, ' ') do |opts|
      opts.separator ""
      opts.separator "Edit options:"

      if options[:show_id]
        opts.on("--id CMR_ID",
                "CMR ID (required).") do |i|
          @options.cmr_id = i
        end
      end

      opts.on("--first_name NAME",
              "Person's first name.") do |fn|
        @options.first_name = fn
      end

      opts.on("--middle_name NAME",
              "Person's middle name.") do |mn|
        @options.middle_name = mn
      end

      opts.on("--last_name NAME",
              "Person's last name.") do |ln|
        @options.last_name = ln
      end

      opts.on("--birth_date DATE",
              "Person's birth date.  Most date formats work, including YYYY-MM-DD.") do |bd|
        @options.birth_date = bd
      end

      opts.on("--approx_age_no_birthday AGE",
              "Approximate age if no birthday set.") do |aanb|
        @options.approximate_age_no_birthday = aanb
      end

      opts.on("--birth_gender GENDER",
              "Birth gender.") do |bg|
        @options.birth_gender = bg
      end

      opts.on("--ethnicity ETHNICITY",
              "Ethnicity.") do |eth|
        @options.ethnicity = eth
      end

      opts.on("--race RACE",
              "Comma-delimited list of races.") do |rc|
        @options.race = rc
      end

      opts.on("--primary_language LANGUAGE",
              "Primary language.") do |pl|
        @options.primary_language = pl
      end

      opts.on("--address_street_number NUMBER",
              "Address street number.") do |asnum|
        @options.address_street_number = asnum
      end

      opts.on("--address_street_name NAME",
              "Address street name.") do |asname|
        @options.address_street_name = asname
      end

      opts.on("--address_unit_number NUMBER",
              "Address unit number.") do |aun|
        @options.address_unit_number = aun
      end

      opts.on("--address_city CITY",
              "Address city.") do |acity|
        @options.address_city = acity
      end

      opts.on("--address_state STATE",
              "Address state.") do |ast|
        @options.address_state = ast
      end

      opts.on("--address_county COUNTY",
              "Address county.") do |acounty|
        @options.address_county = acounty
      end

      opts.on("--address_postal_code CODE",
              "Address postal code.") do |apc|
        @options.address_postal_code = apc
      end

      opts.on("--telephone_location_type LOCATION",
              "Telephone location type.") do |telt|
        @options.telephone_entity_location_type = telt
      end

      opts.on("--telephone_area_code CODE",
              "Telephone area code.") do |tac|
        @options.telephone_area_code = tac
      end

      opts.on("--telephone_number NUMBER",
              "Telephone number.") do |tn|
        @options.telephone_number = tn
      end

      opts.on("--telephone_extension NUMBER",
              "Telephone extension.") do |text|
        @options.telephone_extension = text
      end

      opts.on("--telephone_delete",
              "Delete telephone.") do |tdel|
        @options.telephone_delete = true
      end

      opts.on("--email_address EMAIL",
              "Email address.") do |ea|
        @options.email_address = ea
      end

      opts.on("--email_address_delete",
              "Delete email address.") do |edel|
        @options.email_address_delete = true
      end

    end

    @opts.parse!(args)
    @options
  end

  def populate_form(form)
    if !@options.first_name.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][first_name]'] = @options.first_name
    end
    if !@options.middle_name.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][middle_name]'] = @options.middle_name
    end
    if !@options.last_name.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][last_name]'] = @options.last_name
    end
    if !@options.birth_date.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][birth_date]'] = @options.birth_date
    end
    if !@options.approximate_age_no_birthday.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][approximate_age_no_birthday]'] = @options.approximate_age_no_birthday
    end
    if !@options.birth_gender.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][birth_gender_id]').options.each do |s|
        if s.text == @options.birth_gender
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Birth gender not found in form' if not found
    end
    if !@options.ethnicity.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][ethnicity_id]').options.each do |s|
        if s.text == @options.ethnicity
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Ethnicity not found in form' if not found
    end
    if !@options.race.nil?
      found = 0
      races = @options.race.split(/,\s*/)
      form.field('morbidity_event[interested_party_attributes][person_entity_attributes][race_ids][]').options.each do |s|
        if races.include?(s.text)
          found += 1
          s.select
        else
          s.unselect
        end
      end
      raise 'Race not found in form' if found != races.length
    end
    if !@options.primary_language.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][primary_language_id]').options.each do |s|
        if s.text == @options.primary_language
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Primary language not found in form' if not found
    end
    if !@options.address_street_number.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][canonical_address_attributes][street_number]'] = @options.address_street_number
    end
    if !@options.address_street_name.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][canonical_address_attributes][street_name]'] = @options.address_street_name
    end
    if !@options.address_unit_number.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][canonical_address_attributes][unit_number]'] = @options.address_unit_number
    end
    if !@options.address_city.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][canonical_address_attributes][city]'] = @options.address_city
    end
    if !@options.address_state.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][person_entity_attributes][canonical_address_attributes][state_id]').options.each do |s|
        if s.text == @options.address_state
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Address state not found in form' if not found
    end
    if !@options.address_county.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][person_entity_attributes][canonical_address_attributes][county_id]').options.each do |s|
        if s.text == @options.address_county
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Address county not found in form' if not found
    end
    if !@options.address_postal_code.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][canonical_address_attributes][postal_code]'] = @options.address_postal_code
    end
    # This needs to be reworked as its own restful resource
    if !@options.telephone_entity_location_type.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][entity_location_type_id]').options.each do |s|
        if s.text == @options.telephone_entity_location_type
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Telephone location type not found in form' if not found
    end
    if !@options.telephone_area_code.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][area_code]'] = @options.telephone_area_code
    end
    if !@options.telephone_number.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][phone_number]'] = @options.telephone_number
    end
    if !@options.telephone_extension.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][extension]'] = @options.telephone_extension
    end
    if !@options.telephone_delete.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][_delete]'] = true
    end
    if !@options.email_address.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][email_addresses_attributes][1][email_address]'] = @options.email_address
    end
    if !@options.email_address_delete.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][email_addresses_attributes][1][_delete]'] = true
    end

    form
  end
end
