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

class EventFormsController < ApplicationController
  include ActionView::Helpers::TranslationHelper
  before_filter :find_event
  after_filter TouchEventFilter, :only => [:create, :destroy]

  def index

    unless (
        User.current_user.is_entitled_to_in?(:add_form_to_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id }) ||
          User.current_user.is_entitled_to_in?(:remove_form_from_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id })
      )
      render :partial => "events/permission_denied", :locals => { :reason => t("no_add_remove_forms_privs"), :event => nil }, :layout => true, :status => 403 and return
    end

    event_type = @event.class.name.underscore

    @forms_in_use = @event.form_references.collect { |ref| ref.form }
    form_template_ids_in_use = @forms_in_use.map { |form| form.template_id }

    if form_template_ids_in_use.empty?
      @forms_available = Form.find(:all,
        :conditions => ["status = ? AND event_type = ?", 'Live', event_type],
        :order => "name ASC"
      )
    else
      @forms_available = Form.find(:all,
        :conditions => ["status = ? AND event_type = ? AND template_id NOT IN (?)", 'Live', event_type, form_template_ids_in_use],
        :order => "name ASC"
      )
    end
  end

  def create

    unless (User.current_user.is_entitled_to_in?(:add_form_to_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id }))
      render :partial => "events/permission_denied", :locals => { :reason => t("no_add_remove_forms_privs"), :event => nil }, :layout => true, :status => 403 and return
    end

    forms_to_add = params[:forms_to_add] || []
    if forms_to_add.empty? 
      flash[:error] = t("no_forms_were_selected_for_addition")
    else
      begin
        @event.add_forms(forms_to_add)
        redis.delete_matched("views/events/#{@event.id}/*")
      rescue ArgumentError, ActiveRecord::RecordNotFound
        render :file => static_error_page_path(422), :layout => 'application', :status => 422 and return
      rescue RuntimeError
        render :file => static_error_page_path(500), :layout => 'application', :status => 500 and return
      else
        flash[:notice] = t("forms_in_use_successfully_updated")
      end
    end
    redirect_to event_forms_path(@event)
  end

  def destroy

    unless (User.current_user.is_entitled_to_in?(:remove_form_from_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id }))
      render :partial => "events/permission_denied", :locals => { :reason => t("no_remove_forms_privs"), :event => nil }, :layout => true, :status => 403 and return
    end

    forms_to_remove = params[:forms_to_remove] || []
    if forms_to_remove.empty?
      flash[:error] = t("no_forms_were_selected_for_removal")
    else
      if @event.remove_forms(forms_to_remove)
        redis.delete_matched("views/events/#{@event.id}/*")
        flash[:notice] = t("forms_in_use_successfully_updated")
      else
        flash[:error] = t("unable_to_remove_forms")
      end
    end
    redirect_to event_forms_path(@event)
  end

  def add
    form = Form.find(params[:form_id])
    @event.form_references << FormReference.create(:event_id => @event.id,
                                                    :form_id => form.id,
                                                    :template_id => form.template_id)
  end

  def remove
    @event.forms.delete(Form.find(params[:form_id]))
  end

  protected

  def find_event
    begin
      @event = Event.find(params[:event_id])
    rescue
      render :file => static_error_page_path(404), :layout => 'application', :status => 404 and return
    end
  end
end
