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

describe "/export_columns/show.html.haml" do

  before(:each) do
    disease1 = Factory.build(:disease)
    disease1.expects(:disease_name).twice.returns('Hepatitis A, acute')
    disease2 = Factory.build(:disease)
    disease2.expects(:disease_name).twice.returns('Mumps')
    @export_column = Factory.create(:export_column)
    @export_column.expects(:name).twice.returns('Export Column Name')
    @export_column.expects(:diseases).returns([disease1, disease2])
    @export_column.expects(:export_column_name).returns('some_column')
    @export_column.expects(:export_disease_group).returns(nil)
    @export_column.expects(:type_data).returns('FORM')
    @export_column.expects(:data_type).returns('single_line_text')
    @export_column.expects(:table_name).returns('')
    @export_column.expects(:column_name).returns('')
    @export_column.expects(:is_required).returns(false)
    @export_column.expects(:start_position).returns(69)
    @export_column.expects(:length_to_output).returns(1)
    @export_column.expects(:export_conversion_values).returns([])

    assigns[:export_column] = @export_column
  end

  it "should render associated diseases in view" do
    render "/export_columns/show.html.haml"
    response.should have_tag('span', :text => 'Hepatitis A, acute')
    response.should have_tag('span', :text => 'Mumps')
  end
end
