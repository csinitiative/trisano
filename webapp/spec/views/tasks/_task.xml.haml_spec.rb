require 'spec_helper'

describe "/tasks/_task.xml.haml" do
  include XmlSpecHelper
  before do
    @event = Factory.create(:event_with_task)
    @task = @event.tasks.first
    render '/tasks/_task.xml.haml', :locals => { :task => @task }
  end

  it "should have event task fields" do
    [:name,
     :notes,
     :priority,
     :due_date,
     :repeating_interval,
     :until_date,
     %w(category_id https://wiki.csinitiative.com/display/tri/Relationship+-+TaskCategory),
    ].each do |field, rel|
      assert_xml_field("task", field, rel)
    end
  end
end
