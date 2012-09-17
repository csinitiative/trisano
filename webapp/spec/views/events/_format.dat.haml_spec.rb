require 'spec_helper'

describe "/cdc_events/format.dat.haml" do

  context "cdc event print" do
    class CdcEventTest
      include Export::Cdc::Record
      attr_accessor :interested_party, :jurisdiction, :first_reported_PH_date, :cdc_code, :county_value
      attr_accessor :lab_collection_dates, :races, :lab_test_dates
      attr_accessor :birth_date, :disease_onset_date, :date_diagnosed
      attr_accessor_with_default :age_at_onset, 26
      attr_accessor :age_at_onset_type, :sex, :races, :ethnicity
      attr_accessor :state_case_status_value, :imported_from_value, :outbreak_value, :text_answers
      attr_accessor :value_tos, :start_positions, :lengths, :data_types, :core_field_export_count, :disease_form_ids
      attr_accessor_with_default :MMWR_year, "2012"
      attr_accessor_with_default :MMWR_week, "12"
      attr_accessor_with_default :record_number, "00000000"
      attr_accessor_with_default :event_onset_date, 10.days.ago

      def initialize
        self.races = self.lab_test_dates = self.lab_collection_dates = "{}"
      end
    end


    before do
      mock_user
      assigns[:events] = [CdcEventTest.new, CdcEventTest.new, CdcEventTest.new]
      render :template => "/cdc_events/format.dat.haml", :layout => false
    end

    it "have each record on the new line" do
      response.body.lines.count.should == 3
    end
  end
end
