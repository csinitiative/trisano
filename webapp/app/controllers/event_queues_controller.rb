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

class EventQueuesController < AdminController
  def index
    @event_queues = EventQueue.find(:all, :include => :jurisdiction, :conditions => ["event_queues.jurisdiction_id IN (?)",  User.current_user.jurisdiction_ids_for_privilege(:administer)])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @event_queues }
    end
  end

  def show
    @event_queue = EventQueue.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @event_queue }
    end
  end

  def new
    @event_queue = EventQueue.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @event_queue }
    end
  end

  def edit
    @event_queue = EventQueue.find(params[:id])
  end

  def create
    @event_queue = EventQueue.new(params[:event_queue])

    respond_to do |format|
      if @event_queue.save
        flash[:notice] = t("event_queue_created")
        format.html { redirect_to(@event_queue) }
        format.xml  { render :xml => @event_queue, :status => :created, :location => @event_queue }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event_queue.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @event_queue = EventQueue.find(params[:id])

    respond_to do |format|
      if @event_queue.update_attributes(params[:event_queue])
        flash[:notice] = t("event_queue_updated")
        format.html { redirect_to(@event_queue) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event_queue.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @event_queue = EventQueue.find(params[:id])
    @event_queue.destroy

    respond_to do |format|
      format.html { redirect_to(event_queues_url) }
      format.xml  { head :ok }
    end
  end
end
