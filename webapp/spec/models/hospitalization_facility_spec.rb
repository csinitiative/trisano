# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
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
