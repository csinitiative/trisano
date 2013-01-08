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

describe "events/_disease_info_form.html.haml" do
  before :all do
    @active_disease = Factory(:disease, :active => true)
    @inactive_disease = Factory(:disease, :active => false)
    @sensitive_disease = Factory(:disease, :active => true, :sensitive => true)
    @sensitive_inactive = Factory(:disease, :active => false, :sensitive => true)
  end

  before do
    @user = Factory.build(:user)
    @event = Factory.build(:morbidity_event)
    assigns[:event] = @event
  end

  it "only renders active diseases" do
    render "events/_disease_info_form.html.haml",
      :locals => { :f => ExtendedFormBuilder.new('morbidity_event', @event, template, {}, nil) }
    response.should have_tag('#morbidity_event_disease_event_attributes_disease_id') do
      with_tag('option', "")
      with_tag('option', @active_disease.disease_name)
      without_tag('option', @inactive_disease.disease_name)
      without_tag('option', @sensitive_disease.disease_name)
      without_tag('option', @sensitive_inactive.disease_name)
    end
  end

  it "renders active diseases *and* sensitive disease, if current user has the privilege" do
    @user.stubs(:can_access_sensitive_diseases?).returns(true)
    render "events/_disease_info_form.html.haml",
      :locals => { :f => ExtendedFormBuilder.new('morbidity_event', @event, template, {}, nil) }
    response.should have_tag('#morbidity_event_disease_event_attributes_disease_id') do
      with_tag('option', "")
      with_tag('option', @active_disease.disease_name)
      without_tag('option', @inactive_disease.disease_name)
      with_tag('option', @sensitive_disease.disease_name)
      without_tag('option', @sensitive_inactive.disease_name)
    end
  end
end
