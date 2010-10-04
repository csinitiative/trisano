require File.dirname(__FILE__) + '/../spec_helper'

describe HospitalizationFacility do

  it "should report an error if hospitalization is defined with an admission date, but no place" do
    hospitals_participation = HospitalsParticipation.new(:admission_date => Date.yesterday)
    hf = HospitalizationFacility.create :hospitals_participation => hospitals_participation
    hf.errors.on(:base).should == "Hospitalization Facility can not be blank if hospitalization dates are given."
  end

  it "should report an error if hospitalization is defined with a discharge date, but no place" do
    hospitals_participation = HospitalsParticipation.new(:discharge_date => Date.yesterday)
    hf = HospitalizationFacility.create :hospitals_participation => hospitals_participation
    hf.errors.on(:base).should == "Hospitalization Facility can not be blank if hospitalization dates are given."
  end

  it "should not report an error if hospitalization is defined with a medical record number, but no place" do
    hospitals_participation = HospitalsParticipation.new(:medical_record_number => "123456")
    hf = HospitalizationFacility.create :hospitals_participation => hospitals_participation
    hf.errors.on(:base).should be_nil
  end

end
