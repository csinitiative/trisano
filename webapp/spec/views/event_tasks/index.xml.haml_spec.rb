require 'spec_helper'

describe "/event_tasks/index.xml.haml" do
  include XmlSpecHelper
  before do
    @event = Factory.create(:event_with_task)
    render '/event_tasks/index.xml.haml', :locals => { :event => @event }
  end

  it "should have event task fields" do
    [:name,
     :notes,
     :priority,
     :due_date,
     :repeating_interval,
     :until_date,
     %w(category_id https://wiki.csinitiative.com/display/tri/Relationship+-+TaskCategory),
     %w(user_id     https://wiki.csinitiative.com/display/tri/Relationship+-+User)
    ].each do |field, rel|
      assert_xml_field("event-tasks tasks i0", field, rel)
    end
  end
end
