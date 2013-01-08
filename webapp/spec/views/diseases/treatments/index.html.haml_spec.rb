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

require File.dirname(__FILE__) + '/../../../spec_helper'

describe "disease/:diease_id/treatments" do

  before do
    @disease = Factory(:disease)
    @disease.treatments << Factory(:treatment, :treatment_name => 'Beer')
    assigns[:disease] = @disease

    assigns[:treatments] = [Factory(:treatment, :treatment_name => 'Shot')]
  end

  it "renders a search form" do
    render("/diseases/treatments/index.html.haml")
    response.should have_tag('input#treatment_name')
  end

  it "renders treatments returned in search results" do
    render("/diseases/treatments/index.html.haml")
    response.should have_tag('#search_results a', 'Shot')
  end

  it "renders treatments associated w/ the disease" do
    render("/diseases/treatments/index.html.haml")
    response.should have_tag('#associated_treatments a', 'Beer')
  end

  it "doesn't render table header if there aren't any associated treatments" do
    @disease.disease_specific_treatments.destroy_all
    render("/diseases/treatments/index.html.haml")
    response.should_not have_tag('#associated_treatments')
  end

  it "renders a form for associating search result treatments to the disease" do
    render("/diseases/treatments/index.html.haml")
    response.should have_tag("#search_results form[action=\"/diseases/#{@disease.id}/treatments/associate\"]")
    response.should have_tag("#search_results form input[value='Add']")
  end

  it "renders a form for disassociating disease specific treatments from the disease" do
    render("/diseases/treatments/index.html.haml")
    response.should have_tag("#associated_treatments form[action=\"/diseases/#{@disease.id}/treatments/disassociate\"]")
    response.should have_tag("#associated_treatments form input[value='Remove']")
  end
end
