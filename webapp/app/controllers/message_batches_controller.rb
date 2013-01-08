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
class MessageBatchesController < ApplicationController
  before_filter :can_write, :only => :create

  def show
    @message_batch = MessageBatch.find params[:id]
    @selected = StagedMessage.states[:pending]
    @staged_messages = @message_batch.staged_messages.paginate_by_state(@selected, :page => params[:page], :per_page => 10)
  end

  def create
    @message_batch = MessageBatch.new(params[:message_batch])
    @message_batch.hl7_message = request.body.read if request.format == :hl7

    respond_to do |format|
      if @message_batch.save
        format.hl7  { head :created, :location => @message_batch }
      else
        format.hl7  { head :unprocessable_entity }
      end
    end
  end

  def can_write
    unless User.current_user.is_entitled_to?(:write_staged_message)
      head :unauthorized and return false
    end
  end
end
