require 'spec_helper'

describe ImmutableFormBuilder do
  let(:form) { ImmutableFormBuilder.new(:some_object, @fake_object, @fake_template, {}, nil) }

  context "rendering a new record" do
    before do
      @fake_object = mock('fake object') do
        expects(:new_record?).returns(true)
      end
      @fake_template = mock('fake template')
    end
    
    it "should render the html field" do
      @fake_template.expects(:text_field).with(:some_object, :some_field, {:object => @fake_object})
      form.text_field(:some_field)
    end
  end

  context "rendering an existing record" do
    before do
      @fake_object = mock('fake object') do
        expects(:new_record?).returns(false)
        expects(:some_field).returns('Some field value')
      end
      @fake_template = mock('fake template')
    end

    it "only render the object's value" do
      @fake_template.expects(:h).with('Some field value')
      form.text_field(:some_field)
    end
  end
end
