# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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


def configure_request
  request = mock('Object')
  request.stubs(:xhr?).returns(@xhr_request)
  @template = Object.new
  @template.extend(ApplicationHelper)
  @template.stubs(:request).returns(request)
end

def configure_radio_buttons
  @form_builder = ExtendedFormBuilder.new(nil, nil, @template, nil, nil)
  @radio_buttons = [{:id => 1, :export_conversion_value_id => 200},
                    {:id => 2, :export_conversion_value_id => 201}]
  @result = @form_builder.send(:rb_export_js, @radio_buttons, 'test_id')
end

def configure_drop_downs
  @form_builder = ExtendedFormBuilder.new(nil, nil, @template, nil, nil)
  @select_options = [{:value => 1, :export_conversion_value_id => 200},
                     {:value => 2, :export_conversion_value_id => 201}]

  @result = @form_builder.send(:dd_export_js, @select_options, 'hidden_id', 'select_id')
end

def shared_tests
  it "#{@xhr_request ? 'should not' : 'should'} delay execution until the dom loads" do
    @result.send(@xhr_request ? :should_not : :should) =~ /document.observe\('dom:loaded', function\(\) \{.*\}/m
  end

  it 'should wrap script in a script tag' do
    @result.should =~ /<script type="text\/javascript">.*<\/script>/m
  end

end

def radio_button_tests
  it 'should produce an observer for each radio button' do
    @result.should =~ /\$\('1'\).observe\('click', function\(\) \{/
    @result.should =~ /\$\('2'\).observe\('click', function\(\) \{/
  end

  it 'should write the conversion value to the "id" field for each observer' do
    @result.should =~ /\$\('test_id'\).writeAttribute\('value', '200'\)/
    @result.should =~ /\$\('test_id'\).writeAttribute\('value', '201'\)/
  end
end

def drop_down_tests
  it 'should observe the select field' do
    @result.should =~ /\$\('select_id'\).observe\('change', function\(\) \{/
  end

  it 'should write to option export values to the hidden field' do
    @result.should =~ /if \(this.value == '1'\) \{ \$\('hidden_id'\).writeAttribute\('value', '200'\) \}/
    @result.should =~ /if \(this.value == '2'\) \{ \$\('hidden_id'\).writeAttribute\('value', '201'\) \}/
  end
end


describe ExtendedFormBuilder, 'radio button export js' do

  describe 'during an html request' do

    before(:each) do
      @xhr_request = false
      configure_request
      configure_radio_buttons
    end

    shared_tests

    radio_button_tests

  end
end

describe ExtendedFormBuilder, 'drop down export js' do

  describe 'during an html request' do

    before(:each) do
      @xhr_request = false
      configure_request
      configure_drop_downs
    end

    shared_tests

    drop_down_tests

  end

end

describe ExtendedFormBuilder, 'radio button export js' do

  describe 'during an ajax request' do

    before(:each) do
      @xhr_request = true
      configure_request
      configure_radio_buttons
    end

    shared_tests

    radio_button_tests

  end
end

describe ExtendedFormBuilder, 'drop down export js' do

  describe 'during an html request' do

    before(:each) do
      @xhr_request = true
      configure_request
      configure_drop_downs
    end

    shared_tests

    drop_down_tests

  end

end

describe ExtendedFormBuilder, "rendering a dynamic question" do

  describe 'with a drop down select' do

    it 'should not raise an error with a nil select option value' do
      configure_request
      # don't care about rendering.
      @template.stubs(:select).returns('')
      @template.stubs(:hidden_field_tag).returns('')
      @template.stubs(:content_tag).returns('')
      object = mock('answer') do
        stubs(:id).returns(1)
        stubs(:question_id).returns(1)
        stubs(:new_record?).returns(true)
        stubs(:text_answer).returns('some answer')
      end
      question = mock('question') do
        stubs(:id).returns(1)
        stubs(:is_multi_valued?).returns(false)
        stubs(:data_type).returns(:drop_down)
        stubs(:question_text).returns("This is a question?")
      end
      question_element = mock('question_element') do
        stubs(:question).returns(question)
        stubs(:export_column).returns(nil)
	stubs(:is_required?).returns(false)
      end
      form_elements_cache = mock('form_elements_cache') do
        stubs(:children).returns([Object.new])
        stubs(:children_by_type).returns([])
      end
      select_options = [{:value => nil, :export_conversion_value_id => nil},
                        {:value => 1,   :export_conversion_value_id => 200},
                        {:value => 2,   :export_conversion_value_id => 201}]
      form_builder = ExtendedFormBuilder.new('object_name', object, @template, nil, nil)
      form_builder.stubs(:hidden_field).returns('')
      form_builder.stubs(:get_values).returns(select_options)
      form_builder.stubs(:follow_up_spinner_for).returns('')
      lambda do
        form_builder.send(:dynamic_question,
                          form_elements_cache,
                          question_element,
                          nil,
                          nil)
      end.should_not raise_error
    end
  end
end

describe ExtendedFormBuilder, "returning a core field" do
  before do
    configure_request
    @form_builder = ExtendedFormBuilder.new('morbidity_event', nil, @template, {}, nil)
    @core_field = Factory.create(:cmr_core_field,
                                 :key => 'morbidity_event[test_attribute]')
  end

  it "should return core field" do
    @form_builder.core_field(:test_attribute).should == @core_field
  end

  it "should return a sentinal core field if core field doesn't exist" do
    @form_builder.core_field(:bogus_attribute).should_not be_nil
  end

  it "sentinal if event doesn't have that core field" do
    @form_builder = ExtendedFormBuilder.new('contact_event', nil, @template, {}, nil)
    @form_builder.core_field(:test_attribute).should_not be_nil
  end

  it "sentinal will always return true from #rendered_on_event?" do
    sentinal = @form_builder.core_field(:bogus_attribute)
    sentinal.rendered_on_event?(nil).should be_true
  end

  it "sentinal will return the key that was used in the look up" do
    sentinal = @form_builder.core_field(:bogus_attribute)
    sentinal.key.should == 'morbidity_event[bogus_attribute]'
  end
end

describe ExtendedFormBuilder, "fields_for" do
  before do
    configure_request
  end

  it "should render block, even if association is nil" do
    @template.expects(:fields_for).with do |name, obj, first_arg, options|
      name == "morbidity_event[interested_party_attributes]" &&
        obj.is_a?(InterestedParty) &&
        first_arg == obj &&
        options == { :builder => ExtendedFormBuilder }
    end

    @form = ExtendedFormBuilder.new('morbidity_event', MorbidityEvent.new, @template, {}, nil)
    @form.fields_for(:interested_party, :builder => ExtendedFormBuilder) 
  end
      
end

describe ExtendedFormBuilder::CorePath do

  before do
    @core_path = ExtendedFormBuilder::CorePath['morbidity_event']
  end

  describe "with a base only" do
    it "should generate the default (bracketed) form (for html names)" do
      @core_path.to_s.should == 'morbidity_event'
    end

    it "should generate an underscored form (for html ids)" do
      @core_path.underscore.should == 'morbidity_event'
    end

    it "should return the first segment" do
      @core_path.first.should == 'morbidity_event'
    end
  end

  shared_examples_for "a complex core path" do
    it "should generate the default (bracketed) form (for html names)" do
      @core_path.to_s.should == 'morbidity_event[interested_party][person_entity]'
    end

    it "should generate an underscored form (for html ids)" do
      @core_path.underscore.should == 'morbidity_event_interested_party_person_entity'
    end

    it "should return the first segment" do
      @core_path.first.should == 'morbidity_event'
    end
  end

  describe "building a complex path" do
    before do
      @core_path << 'interested_party' << 'person_entity'
    end

    it_should_behave_like "a complex core path"
  end

  describe "starting w/ a complex base" do
    before do
      @core_path = ExtendedFormBuilder::CorePath['morbidity_event[interested_party][person_entity]']
    end

    it_should_behave_like "a complex core path"
  end

end
