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

describe CodeSelectCache do

  before do
    given_external_codes 'fakeext', %w(Y N UNK)
    given_codes 'fakeinternal', %w(ALT DEF)
    @cache = CodeSelectCache.new
    @results = @cache.drop_down_selections('fakeext')
  end

  it "should return external codes by code name" do
    @results.map(&:the_code).sort.should == %w(N UNK Y)
  end

  it "should not go back to the database for codes, once they're loaded" do
    given_external_codes 'fakeext', %w(M)
    @cache.drop_down_selections('fakeext').map(&:the_code).sort.should == %w(N UNK Y)
  end

  it "should return codes by code name" do
    @cache.drop_down_selections('fakeinternal').map(&:the_code).sort.should == %w(ALT DEF)
  end

  describe "drop down selections" do
    before do
      given_external_codes('fakeext', %w(Y N UNK))
      given_codes('fakeint', %w(ALT TLT))
      given_codes('placetype', %w(C J H L))
      @disease = given_disease_specific_external_codes('Dengue', 'fakeext', %w(M))
      @event = Factory.create(:morbidity_event)
      @event.create_disease_event(:disease => @disease)
      @cache = CodeSelectCache.new
    end

    it "should return external codes by code name" do
      results = @cache.drop_down_selections('fakeext')
      results.map(&:the_code).sort.should == %w(N UNK Y)
    end

    it "should return internal codes for drop down selections, by code name" do
      results = @cache.drop_down_selections('fakeint')
      results.map(&:the_code).sort.should == %w(ALT TLT)
    end

    it "should exclude jurisdictions from drop down selections to prevent accidental jurisdiction creation" do
      results = @cache.drop_down_selections('placetype')
      results.should_not be_empty
      results.map(&:the_code).include?('J').should be_false
    end

    it "should return disease specific external codes for drop down selections" do
      results = @cache.drop_down_selections('fakeext', @event)
      results.map(&:the_code).sort.should == %w(M N UNK Y)
    end

    it "selections are unaffected by settings for other diseases" do
      other_disease = Factory.create :disease
      given_external_codes('fakeext', %w(Y N UNK)).each do |code|
        code.hide_for_disease other_disease
      end
      results = @cache.drop_down_selections('fakeext', @event)
      results.map(&:the_code).sort.should == %w(M N UNK Y)
    end

    it "should not return codes hidden on the currenct disease event" do
      given_external_codes('fakeext', %w(Y UNK)).each do |code|
        code.hide_for_disease @disease
      end
      results = @cache.drop_down_selections('fakeext', @event)
      results.map(&:the_code).sort.should == %w(M N)
    end
  end

end
