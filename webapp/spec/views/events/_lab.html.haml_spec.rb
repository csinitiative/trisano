require 'spec_helper'

describe "events/_lab.html.haml" do

  it "should not show deleted labs in the labs drop down" do
    lab_entity = create_lab!('Labmart')
    deleted = create_lab!('Labgreens')
    deleted.update_attribute('deleted_at', DateTime.now)
    
    render "events/_lab.html.haml", :locals => { :prefix => 'pffft_event', :uniq_id => 'TEST', :lab => Lab.new }
    response.should have_tag('option', lab_entity.place.name)
    response.should_not have_tag('option', deleted.place.name)
  end
end
