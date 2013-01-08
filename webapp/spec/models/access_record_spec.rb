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

require File.dirname(__FILE__) + '/../spec_helper'

describe AccessRecord do

  before(:each) do
    @valid_attributes = {
        :user => Factory.create(:user),
        :event => Factory.create(:morbidity_event),
        :reason => "Oh, I don't know, I just kinda feel like it.",
        :access_count => 0
    }
  end

  it "should be valid with valid attributes" do
    access_record = AccessRecord.new(@valid_attributes)
    access_record.should be_valid
  end

  it "should be invalid when missing a user" do
    attributes = @valid_attributes.reject { |key, value| key == :user }
    access_record = AccessRecord.new(attributes)
    access_record.should_not be_valid
    access_record.errors[:user_id].include?("can't be blank").should be_true
  end

  it "should be invalid when missing an event" do
    attributes = @valid_attributes.reject { |key, value| key == :event }
    access_record = AccessRecord.new(attributes)
    access_record.should_not be_valid
    access_record.errors[:event_id].include?("can't be blank").should be_true
  end

  it "should be invalid when missing a reason" do
    attributes = @valid_attributes.reject { |key, value| key == :reason }
    access_record = AccessRecord.new(attributes)
    access_record.should_not be_valid
    access_record.errors[:reason].include?("can't be blank").should be_true
  end

  it "should still be valid when missing an access count b/c the database default is 0" do
    attributes = @valid_attributes.reject { |key, value| key == :access_count }
    access_record = AccessRecord.new(attributes)
    access_record.should be_valid
  end
  
end
