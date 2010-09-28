class MessageBatchesController < ApplicationController
  before_filter :can_write, :only => :create

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
