# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

class StagedMessagesController < ApplicationController

  before_filter :can_manage, :only => [:index, :show, :discard, :event_search, :event]
  before_filter :can_write, :only => [:new, :create, :edit, :update, :destroy]

  def index
    @selected = StagedMessage.states.has_value?(params[:message_state]) ? @selected = params[:message_state] : @selected = StagedMessage.states[:pending]
    @staged_messages = StagedMessage.paginate_by_state(@selected, :order => "created_at DESC", :page => params[:page], :per_page => 10)
  end

  def show
    @staged_message = StagedMessage.find(params[:id])
  end

  def new
    @staged_message = StagedMessage.new
  end

  def edit
    @staged_message = StagedMessage.find(params[:id])
  end

  def create
    @staged_message = StagedMessage.new(params[:staged_message])
    @staged_message.hl7_message ||= request.body.read if request.format == :hl7

    respond_to do |format|
      if @staged_message.save
        flash[:notice] = t("staged_message_successfully_created")
        format.html { redirect_to(@staged_message) }
        format.hl7  { render :inline => '<%= @staged_message.ack.to_hl7 %>',
          :status => :created, :location => @staged_message }
      else
        format.html { render :action => "new", :status => :bad_request }
        format.hl7  { render :inline => '<%= @staged_message.ack.to_hl7 %>',
          :status => :unprocessable_entity }
      end
    end
  end

  # PUT /staged_messages/1
  # PUT /staged_messages/1.xml
  def update
    @staged_message = StagedMessage.find(params[:id])

    if @staged_message.update_attributes(params[:staged_message])
      flash[:notice] = t("staged_message_successfully_updated")
      redirect_to(@staged_message)
    else
      render :action => "edit"
    end
  end

  def destroy
    @staged_message = StagedMessage.find(params[:id])
    @staged_message.destroy

    redirect_to(staged_messages_url)
  end

  def discard
    @staged_message = StagedMessage.find(params[:id])
    begin
      @staged_message.discard
    rescue
      flash[:error] = t("could_not_discard_message_event", :message => $!)
      redirect_to(staged_message_path(@staged_message))
    else
      flash[:notice] = t("staged_message_discarded")
      redirect_to(staged_messages_url)
    end
  end

  def event_search
    @staged_message = StagedMessage.find(params[:id])
    if params[:name]
      dob = begin Date.parse(params[:birth_date]) || nil rescue nil end
      @results = HumanEvent.find_by_name_and_bdate(
        :fulltext_terms => params[:name],
        :birth_date => dob)
    end
  end

  def event
    begin
      staged_message = StagedMessage.find(params[:id])

      if params[:event_id]
        event = Event.find(params[:event_id])
        msg_string = t("existing")
      else
        event = staged_message.new_event_from(params[:entity_id])
        msg_string = t("new")
      end

      staged_message.assigned_event = event
    rescue Exception => e
      logger.error(e)
      flash[:error] = t("message_assignment_failed", :msg_string => msg_string, :message => $!)
    else
      flash[:notice] = t("message_assignment_successful", :msg_string => msg_string, :note => staged_message.note)
    end
    redirect_to(staged_message_path(staged_message))
  end

  def search
    if params.delete(:do) == "Search"
      begin
        @staged_messages = StagedMessage.find_by_search params
      rescue
        flash.now[:error] = t("staged_message_search_failed")
      end
    end
  end

  private

  def can_manage
    unless User.current_user.is_entitled_to?(:manage_staged_message)
      render :partial => 'permission_denied', :layout => true, :locals => { :reason => t("no_manage_staged_message_privs") }, :status => :forbidden and return
    end
  end

  def can_write
    unless User.current_user.is_entitled_to?(:write_staged_message)
      render :partial => 'permission_denied', :layout => true, :locals => { :reason =>  t("no_create_or_modify_staged_message_privs")}, :status => :forbidden and return
    end
  end

end
