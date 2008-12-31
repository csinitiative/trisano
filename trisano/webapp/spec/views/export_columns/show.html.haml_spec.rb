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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/export_columns/show.html.haml" do
  
  before(:each) do
    disease1 = mock_model(Disease)
    disease1.should_receive(:disease_name).and_return('Hepatitis A, acute')
    disease2 = mock_model(Disease)
    disease2.should_receive(:disease_name).and_return('Mumps')
    @export_column = mock_model(ExportColumn)
    @export_column.should_receive(:name).twice.and_return('Export Column Name')
    @export_column.should_receive(:diseases).and_return([disease1, disease2])
    @export_column.should_receive(:export_column_name).and_return('some_column')
    @export_column.should_receive(:export_disease_group).and_return(nil)
    @export_column.should_receive(:type_data).and_return('FORM')
    @export_column.should_receive(:data_type).and_return('single_line_text')
    @export_column.should_receive(:table_name).and_return('')
    @export_column.should_receive(:column_name).and_return('')
    @export_column.should_receive(:is_required).and_return(false)
    @export_column.should_receive(:start_position).and_return(69)
    @export_column.should_receive(:length_to_output).and_return(1)
    @export_column.should_receive(:export_conversion_values).and_return([])
    @export_column.should_receive(:disease_ids).and_return([disease1.id, disease2.id])

    assigns[:export_column] = @export_column
  end

  it "should render associated diseases in view" do
    render "/export_columns/show.html.haml"
    response.should have_tag('td', :text => 'Hepatitis A, acute')
    response.should have_tag('td', :text => 'Mumps')
  end
end
