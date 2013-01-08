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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/form_elements/create.rjs" do

  def create_and_add_to_form(element_type, form)
    form_element = Factory.build(element_type, {
      :parent_element_id => form.investigator_view_elements_container.id})
    form_element.save_and_add_to_form
    form_element
  end

  def do_render(element_type, form)
    assigns[:form_element] = create_and_add_to_form(element_type, form)
    render "form_elements/create.rjs"
  end

  before do
    @form = Factory.build(:form)
    @form.save_and_initialize_form_elements
    assigns[:form] = @form

    assigns[:library_elements] = []

    flash[:notice] = 'Test notice'
  end

  it "renders view element" do
    do_render(:view_element, @form)
  end

  it "renders core view element" do
    do_render(:core_view_element, @form)
  end

  it "renders core field elements" do
    do_render(:core_field_element, @form)
  end

  it "renders before core field element" do
    do_render(:before_core_field_element, @form)
  end

  it "renders after core field element" do
    do_render(:after_core_field_element, @form)
  end

  it "renders section element" do
    do_render(:section_element, @form)
  end

  it "renders group element" do
    do_render(:group_element, @form)
  end

  it "renders question element" do
    do_render(:question_element, @form)
  end

  it "renders follow up element" do
    do_render(:follow_up_element, @form)
  end

  it "renders value set element" do
    do_render(:value_set_element, @form)
  end

  it "renders value element" do
    do_render(:value_element, @form)
  end

end
