require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CoreFieldsDisease do
  include DiseaseSpecHelper
  include CoreFieldSpecHelper

  it { should belong_to(:disease) }
  it { should belong_to(:core_field) }

  it "requires a disease" do
    cfd = CoreFieldsDisease.create
    cfd.errors.on(:disease).should == "can't be blank"
  end

  it "requires a core field" do
    cfd = CoreFieldsDisease.create
    cfd.errors.on(:core_field).should == "can't be blank"
  end

  describe "creating associations" do

    before do
      given_a_disease_named('African Tick Bite Fever')
      given_core_fields_loaded
      @disease_name = "African Tick Bite Fever"
      @fields = YAML::load_file(File.join(File.dirname(__FILE__), '../../db/defaults/core_fields.yml'))
    end

    it "should associate core fields, by key, with diseases, by name" do
      lambda do
        CoreFieldsDisease.create_associations(@disease_name, @fields)
      end.should change(CoreFieldsDisease, :count).by(@fields.size)
      Disease.find_by_disease_name(@disease_name).core_fields.size.should == @fields.size
    end

  end

end
