require 'spec_helper'

describe DiseaseSpecificTreatment do

  it { should belong_to(:disease) }
  it { should belong_to(:treatment) }
  it { should validate_presence_of(:disease_id) }
  it { should validate_presence_of(:treatment_id) }

end
