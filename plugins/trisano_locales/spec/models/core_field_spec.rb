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

require 'spec_helper'

describe CoreField, "after modifications for translated help text"  do

  before do
    @cf = Factory.build :cmr_core_field
    I18n.locale = :en
    @cf.help_text = 'En help text'
    I18n.locale = :test
    @cf.help_text = 'Test help text'
    I18n.locale = :en
  end

  after do
    I18n.locale = :en
  end

  it "has many core field translations" do
    should have_many(:core_field_translations)
  end

  it "assigns help text based on the current locale" do
    I18n.locale = :en
    @cf.help_text.should == 'En help text'
    I18n.locale = :test
    @cf.help_text.should == 'Test help text'
  end

  it "saves a translation record for each locale assigned a help_text" do
    @cf.save!
    @cf.core_field_translations.map(&:locale).sort.should == ['en', 'test']
  end

  it "reload clears assigned help text" do
    @cf.save!
    @cf.help_text = "new assignment"
    @cf.reload
    @cf.help_text.should == "En help text"
  end

  it "assigns help_text through the constructor" do
    cf = CoreField.new(:help_text => 'Does this get assigned?')
    cf.help_text.should == 'Does this get assigned?'
  end
end
