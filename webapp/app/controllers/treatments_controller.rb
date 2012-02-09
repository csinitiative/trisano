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

class TreatmentsController < AdminController

  before_filter :load_disease, :only => [:index, :associate, :disassociate, :apply_to]
  before_filter :load_treatments, :only => [:index, :merge]

  def index
    if @disease
      render :template => '/diseases/treatments/index'
    else
      render :action => 'index'
    end
  end

  def associate
    head(:not_found) && return unless @disease
    if @disease.add_treatments(params[:associations])
      expire_fragment(%r{/events/})

      flash[:notice] = t(:disease_treatments_updated)
    else
      flash[:error] = t(:update_failed)
    end
    respond_to do |format|
      format.html { redirect_to(disease_treatments_url(@disease)) }
    end
  end

  def disassociate
    head(:not_found) && return unless @disease
    if @disease.remove_treatments(params[:associations])
      expire_fragment(%r{/events/})

      flash[:notice] = t(:disease_treatments_updated)
    else
      flash[:error] = t(:update_failed)
    end
    respond_to do |format|
      format.html { redirect_to(disease_treatments_url(@disease)) }
    end
  end

  def apply_to
    head(:not_found) && return unless @disease
    if @disease.apply_treatments_to(params[:other_disease_ids])
      expire_fragment(%r{/events/})

      flash[:notice] = t(:disease_treatments_copied)
    else
      flash[:error] = t(:update_failed)
    end
    respond_to do |format|
      format.html { redirect_to disease_treatments_url(@disease) }
    end
  end

  def new
    @treatment = Treatment.new
  end

  def create
    @treatment = Treatment.new(params[:treatment])

    respond_to do |format|
      if @treatment.save
        expire_fragment(%r{/events/})

        flash[:notice] = t("treatment_created")
        format.html { redirect_to(@treatment) }
        format.xml  { render :xml => @treatment, :status => :created, :location => @treatment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @treatment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @treatment = Treatment.find(params[:id])
  end

  def update
    @treatment = Treatment.find(params[:id])

    respond_to do |format|
      if @treatment.update_attributes(params[:treatment])
        expire_fragment(%r{/events/})

        flash[:notice] = t("treatment_updated")
        format.html { redirect_to(@treatment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @treatment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @treatment = Treatment.find(params[:id])
  end

  def merge
    @treatment = Treatment.find(params[:id])
    render :action => "index"
  end

  def duplicates
    @treatment = Treatment.find(params[:id])

    if @treatment.merge(params[:to_merge])
      expire_fragment(%r{/events/})

      flash[:notice] = 'Merge successful.'
    else
      flash[:error] = @treatment.errors["base"]
    end

    redirect_to request.env["HTTP_REFERER"]
  end

  private

  def load_treatments
    scope = Treatment.scoped(:order => 'treatment_name ASC')

    unless params[:treatment_name].blank?
      scope = scope.scoped(:conditions => ["treatment_name ILIKE ?", "%#{params[:treatment_name]}%"])
    end

    if @disease and not @disease.treatment_ids.empty?
      scope = scope.scoped(:conditions => ["id NOT IN (?)", @disease.treatment_ids])
    end

    @treatments = scope
  end

  def load_disease
    @disease = Disease.find(params[:disease_id]) if params[:disease_id]
  end
end
