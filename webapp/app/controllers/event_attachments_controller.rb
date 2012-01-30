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


class EventAttachmentsController < ApplicationController

  before_filter :find_event
  before_filter :can_update_event?, :only => [:create, :new, :destroy]
  before_filter :can_view_event?, :only => [:index, :new, :show]
  after_filter TouchEventFilter, :only => [:create, :destroy]
  
  def index
  end

  def show
    @attachment = @event.attachments.find(params[:id])
    
    send_data(@attachment.current_data,
      :type  => @attachment.content_type,
      :filename => @attachment.filename,
      :disposition => 'attachment')
  rescue
    render :file => static_error_page_path(404), :layout => 'application', :status => 404 and return
  end

  def new
    @attachment = Attachment.new
    @attachment.event_id = @event.id
  end

  def create

    begin

    @attachment = Attachment.new(params[:attachment])

    respond_to do |format|
      if @attachment.save
        flash[:notice] = t("event_attachement_created")
        format.html {redirect_to request.env["HTTP_REFERER"] }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def destroy
    begin
      @attachment = @event.attachments.find(params[:id])
      @attachment.destroy
      respond_to do |format|
        format.html do
          flash[:notice] = t("event_attachement_deleted")
          redirect_to request.env["HTTP_REFERER"]
        end
        format.js
      end
    rescue
      logger.error $!.message
      respond_to do |format|
        format.html do 
          flash[:error] = t("failed_to_delete_event_attachment")
          redirect_to request.env["HTTP_REFERER"]
        end
        format.js do
          render(:update) do |page| 
            page << <<-JAVASCRIPT
              var spinner = $('attachment_#{params[:id]}_spinner');
              if (spinner != null) {
                spinner.hide();
              }
              alert('#{t("failed_to_delete_event_attachment")}');
            JAVASCRIPT
          end
        end
      end
    end
  end

end
