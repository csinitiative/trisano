require 'csv'

module SearchHelper

  def render_csv(cmrs)
    csv = ''
    return 'Your search returned no results' if cmrs.blank?
    fields = %w(record_number last_name first_name middle_name birth_date age disease_name event_onset_date gender jurisdiction_name created_at lhd_investigation_status city county)
    header = %w(record_number last_name first_name middle_name birth_date age disease_name onset_date       gender jurisdiction_name entered_on investigation_status     city county)
    CSV::Writer.generate(csv) do |writer|
      writer << header
      cmrs.each do |cmr|
        writer << fields.collect do |field_name|
          if field_name.eql? 'age'
            calculate_age(cmr.birth_date.to_date) if cmr.birth_date
          else
            cmr.send(field_name)
          end
        end
      end
    end
    csv
  end

end
