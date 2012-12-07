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

  describe "on events" do
    
    before(:each) do
      @event = Factory.create(:morbidity_event)
      @user = Factory.create(:user)
      User.current_user=(@user)
      @event.add_note("First note")
      @event.add_note("Second note, clinical", "clinical")
      @event.add_note("Third note, explicitly admin", "administrative")
    end

    it "should set the author to the current user by default" do
      @event.notes.each do |note|
        note.user_id.should == @user.id
      end
    end

    it "should not make the current user the author if another is explicitly assigned" do
      author = Factory.create(:user)
      note = @event.add_note "new note", "clinical", :user => author
      note.user.should == author
    end

    it "should make the first note an admin note as it is the default when no note type is supplied" do
      @event.notes.first.note_type.should == "administrative"
    end

    it "adding a note as another user should not change previous note ownership on an event" do
      @another_user = Factory.create(:user)
      User.current_user=(@another_user)
      @event.add_note("Note by a second user")

      @event.notes.first.user.id.should == @another_user.id
      @event.notes[1].user.id.should == @user.id
      @event.notes[2].user.id.should == @user.id
      @event.notes[3].user.id.should == @user.id
    end

  end
end
