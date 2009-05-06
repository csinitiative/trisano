require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LabMessage do
  before(:each) do
    @valid_attributes = {
      :hl7_message => ARUP1_MSG
    }
  end

  it "should create a new instance given valid attributes" do
    LabMessage.create!(@valid_attributes)
  end

  it "should not be valid if there's no HL7 message" do
    LabMessage.new.should_not be_valid
  end

  describe 'received from ARUP' do
    
    before :each do
      @lab_message = LabMessage.create(:hl7_message => ARUP1_MSG)
    end

    it 'should return HL7 version' do
      @lab_message.patient_name.should == 'LIN GENYAO     L'
    end

    it 'should return the lab' do
      @lab_message.lab.should == '13954-3 Hepatitis Be Antigen LN'
    end

    it 'should return the hl7 version' do
      @lab_message.hl7_version.should == '2.3.1'
    end

    it 'should return the lab result' do
      @lab_message.lab_result.should == 'Positive'
    end

  end

  describe 'reading HL7' do

    it 'should contain a message header' do
      @lab_message = LabMessage.new(:hl7_message => 'junk')
      @lab_message.should_not be_valid
      @lab_message.errors.on(:hl7_message).should be_true
    end

  end
end

ARUP1_MSG = <<ARUP1
MSH|^~\&|ARUP|ARUP LABORATORIES^46D0523979^CLIA|UTDOH|UT|200903261645||ORU^R01|200903261645128667|P|2.3.1|1\r
PID|1||17744418^^^^MR||LIN^GENYAO^^^^^L||19840810|M||U^Unknown^HL70005|215 UNIVERSITY VLG^^SALT LAKE CITY^UT^84108^^M||^^PH^^^801^5854967|||||||||U^Unknown^HL70189\r
ORC||||||||||||^ROSENKOETTER^YUKI^K|||||||||University Hospital UT|50 North Medical Drive^^Salt Lake City^UT^84132^USA^B||^^^^^USA^B\r
OBR|1||09078102377|13954-3^Hepatitis Be Antigen^LN|||200903191011|||||||200903191011|X|^ROSENKOETTER^YUKI^K|||||||||F||||||9^Unknown\r
OBX|1|ST|13954-3^Hepatitis Be Antigen^LN|1|Positive||Negative||||F|||200903210007\r
ARUP1

