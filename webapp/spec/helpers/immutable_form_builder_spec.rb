# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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
