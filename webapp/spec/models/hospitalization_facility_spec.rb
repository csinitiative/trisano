require File.dirname(__FILE__) + '/../spec_helper'

describe HospitalizationFacility do

  it "should report error if hospitalization defined, but no place" do
    hospitals_participation = HospitalsParticipation.new
    hf = HospitalizationFacility.create :hospitals_participation => hospitals_participation
    hf.errors.on(:base).should == "Hospitalization Facility can not be blank if hospitalization dates or medical record number are given."
  end

end
