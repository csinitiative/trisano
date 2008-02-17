require File.dirname(__FILE__) + '/../../spec_helper'

describe RecordId do
  
  it "should handle bogus constructor args" do
    lambda {RecordId.new}.should raise_error(ArgumentError, "RecordId initialize takes 1, 2, or 3 arguments.")
    lambda {RecordId.new(1, 2, 3, 4)}.should raise_error(ArgumentError, "RecordId initialize takes 1, 2, or 3 arguments.")    
    lambda {RecordId.new(String.new)}.should raise_error(ArgumentError, "RecordId: Expected Integer")
    lambda {RecordId.new(String.new, 1)}.should raise_error(ArgumentError, "RecordId: Expected Date")
    lambda {RecordId.new(Date.new(2007, 1, 1), String.new)}.should raise_error(ArgumentError, "RecordId: Expected Integer")
    lambda {RecordId.new(Date.new(2007, 1, 1), 1, String.new)}.should raise_error(ArgumentError, "RecordId: Expected Symbol")

  end  
  
  it "should be 2007900032 for the 32nd NETSS record entered in 2007" do        
    RecordId.new(Date.new(2007, 1, 1), 32, :netss).value.should == "2007900032"    
  end
  
  it "should be 2008500005 for the 5th record entered directly into NEDSS in 2008" do    
    RecordId.new(5).value.should == "2008500005"
  end
  
  it "should be 2009500005 for the 5th record entered directly into NEDSS in 2009" do
    RecordId.new(Date.new(2009, 1, 1), 5).value.should == "2009500005"
  end  
  
  it "should be 2050000001 for the 1st record entered directly into NEDSS in 2050" do
    RecordId.new(Date.new(2050, 1, 1), 1).value.should == "2050500001"
  end    
  
  it "should be 2008599999  for the 599,999th record entered directly into NEDSS in 2008" do
    RecordId.new(Date.new(2008, 1, 1), 99999).value.should == "2008599999"
  end  
  
  it "should be 2008900005 for the 5th NETSS record entered in 2008" do
    RecordId.new(Date.new(2008, 1, 1), 5, :netss).value.should == "2008900005"
  end
  
  it "should be 2002899999 for the 99,999th TIMS record entered in 2002" do
    RecordId.new(Date.new(2002, 1, 1), 99999, :tims).value.should == "2002899999"
  end
  
  it "should be 2002712345 for the 12,345 STD_MIS record entered in 2002" do
    RecordId.new(Date.new(2002, 1, 1), 12345, :stdmis).value.should == "2002712345"
  end

  it "should be 1999654321 for the 54,321th HARS record entered in 1999" do
    RecordId.new(Date.new(1999, 1, 1), 54321, :hars).value.should == "1999654321"
  end
  
  it "should work with a random number" do
    random = rand(99999)
    expected = "1999" +"6" + random.to_s
    RecordId.new(Date.new(1999, 1, 1), 54321, :hars).value.should == "1999654321"
  end
  
  it "should handle numbers that are too large" do
    #TODO
    pending
  end
end

