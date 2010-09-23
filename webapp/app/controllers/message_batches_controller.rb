class MessageBatchesController < ApplicationController
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
end
