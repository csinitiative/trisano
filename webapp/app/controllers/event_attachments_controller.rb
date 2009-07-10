# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

class EventAttachmentsController < ApplicationController

  before_filter :find_event
  before_filter :can_update_event?, :only => [:create]
  before_filter :can_view_event?, :only => [:index, :new, :show]
  
  def index
    @attachment = Attachment.new
    @attachment.event_id = @event.id
    render :action => 'new'
  end

  def show
    @attachment = Attachment.find(params[:id])
    
    send_data(@attachment.current_data,
      :type  => @attachment.content_type,
      :filename => @attachment.filename,
      :disposition => 'attachment')
    
  rescue
    render :file => "#{RAILS_ROOT}/public/404.html", :layout => 'application', :status => 404 and return
  end

  def new
    @attachment = Attachment.new
    @attachment.event_id = @event.id
  end

  def create
    @attachment = Attachment.new(params[:attachment])

    respond_to do |format|
      if @attachment.save
        flash[:notice] = 'Attachment was successfully created.'
        format.html {redirect_to request.env["HTTP_REFERER"] }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    
    respond_to do |format|
      begin
        @attachment.destroy
        flash[:notice] = 'Attachment was successfully deleted.'
        format.html {redirect_to request.env["HTTP_REFERER"]}
      rescue
        flash[:error] = 'Failed to delete attachment.'
        format.html {redirect_to request.env["HTTP_REFERER"]}
      end
    end
  end

end
