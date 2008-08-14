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

class TreatmentsController < ApplicationController

  before_filter :get_cmr

  # GET /treatments
  def index
    @participations_treatments = @event.active_patient.participations_treatments.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /treatments/1
  def show
    @participations_treatment = @event.active_patient.participations_treatments.find(params[:id])

    respond_to do |format|
      format.html # show.html.haml
    end
  end

  # GET /treatments/new
  def new
    @participations_treatment = ParticipationsTreatment.new
    render :layout => false
  end

  # GET /treatments/1/edit
  def edit
    @participations_treatment = @event.active_patient.participations_treatments.find(params[:id])
    render :layout => false
  end

  # POST /treatments
  def create
    @participations_treatment = ParticipationsTreatment.new(params[:participations_treatment])

    if (@event.active_patient.participations_treatments << @participations_treatment)
      render(:update) do |page|
        page.replace_html "treatment-list", :partial => 'treatments/index'
        page.call "RedBox.close"
      end
    else
      # This will do for now.
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@participations_treatment.errors.full_messages}"
      end
    end
  end

  # PUT /treatments/1
  def update
    @participations_treatment = @event.active_patient.participations_treatments.find(params[:id])

    if @participations_treatment.update_attributes(params[:participations_treatment])
      render(:update) do |page|
        page.replace_html "treatment-list", :partial => 'treatments/index'
        page.call "RedBox.close"
      end
    else
      # This will do for now.
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@participations_treatment.errors.full_messages}"
      end
    end
  end

  # DELETE /treatments/1
  def destroy
    head :method_not_allowed
  end

  private

  def get_cmr
    @event = Event.find(params[:cmr_id])
  end
end
