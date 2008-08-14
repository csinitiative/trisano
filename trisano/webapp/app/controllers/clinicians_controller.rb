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

class CliniciansController < ApplicationController

  before_filter :get_cmr

  def index
    head :method_not_allowed
  end

  def show
    head :method_not_allowed
  end

  def new
    @clinician = Entity.new(:person => {},
      :entities_location => { :entity_location_type_id => ExternalCode.unspecified_location_id,
        :primary_yn_id => ExternalCode.yes_id }
    ) 
    render :layout => false
  end

  def edit
    @clinician = @event.clinicians.find(params[:id])
    render :layout => false
  end

  def create
    @clinician = Participation.new(:role_id => Event.participation_code('Treated By'), :active_secondary_entity => params[:entity])

    if (@event.clinicians << @clinician)
      render(:update) do |page|
        page.replace_html "clinicians-list", :partial => 'clinicians/index'
        page.call "RedBox.close"
      end
    else
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@clinician.active_secondary_entity.person.errors.full_messages}"
      end
    end
  end

  def update
    @clinician = @event.clinicians.find(params[:id])

    if @clinician.active_secondary_entity.update_attributes(params[:entity])
      render(:update) do |page|
        page.replace_html "clinicians-list", :partial => 'clinicians/index'
        page.call "RedBox.close"
      end
    else
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@clinician.active_secondary_entity.person.errors.full_messages}"
      end
    end
  end

  def destroy
    head :method_not_allowed
  end
  
  private

  def get_cmr
    @event = Event.find(params[:cmr_id])
  end
  
end
