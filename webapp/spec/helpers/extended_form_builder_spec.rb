# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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
  request = mock(Object)
  request.stub!(:xhr?).and_return(@xhr_request)
  @template = Object.new
  @template.extend(ApplicationHelper)
  @template.stub!(:request).and_return(request)
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
