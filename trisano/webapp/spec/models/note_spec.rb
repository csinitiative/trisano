# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

describe Note do
  before(:each) do
    @note = Note.new(:note => "A note")
    @note.user_id = 1
  end

  it "should be valid" do
    @note.should be_valid
  end

  it "should not be valid withot a note" do
    @note.note = ""
    @note.should_not be_valid
  end

  it "should not be valid withot a user" do
    @note.user_id = nil
    @note.should_not be_valid
  end

  describe "with fixtures" do
    fixtures :notes, :users, :events

    before(:each) do
      @note = notes(:marks_note_1)
    end

    it "should have an event" do
      @note.event_id.should == events(:marks_cmr).id
    end

    it "should have a user" do
      @note.user_id.should == users(:default_user).id
    end
  end
end
