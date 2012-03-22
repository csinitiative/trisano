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
include ActionController::TestProcess #required by fixture_file_upload
describe Attachment do

  it "shouldn't be valid without a file uploaded" do
    @attachment = Attachment.new
    @attachment.valid?
    @attachment.should_not be_valid
  end

  # The following is a working example of testing attachments with a fixture file. All content
  # types are not exercised, however. Not sure if there's value in that.
  it "should be valid with a application/pdf content type" do
    @attachment = Attachment.new( { :uploaded_data => fixture_file_upload('files/test-attachment', 'application/pdf') } )
    @attachment.valid?
    @attachment.should be_valid
  end

  it 'should not allow an update with an invalid category' do
    @attachment = Attachment.new( { :uploaded_data => fixture_file_upload('files/test-attachment', 'application/pdf') } )
    @attachment.save!
    @attachment.category = 'not_a_real_status'
    @attachment.save.should be_false
    @attachment.errors.on(:category).should_not be_nil
  end

  it 'should allow updates with valid categories' do
    @attachment = Attachment.new( { :uploaded_data => fixture_file_upload('files/test-attachment', 'application/pdf') } )
    @attachment.save!
    Attachment.valid_categories.each do |category|
      @attachment.category = category
      @attachment.save.should be_true
    end
  end

end
