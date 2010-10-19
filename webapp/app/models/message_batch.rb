class MessageBatch < ActiveRecord::Base
  has_many :staged_messages, :dependent => :nullify,
    :after_remove => :message_removed

  def validate
    # parse outer batch envelope
    # retrieve each nested, raw HL7 message
    begin
      HL7::Message.parse_batch(hl7_message) do |message|
        staged_message = StagedMessage.new :hl7_message => message
        staged_messages << staged_message if staged_message.valid?
      end
    rescue => errmsg
      record_error errmsg
    end if new_record?

    # If we receive an empty batch or a batch with all invalid
    # messages, we don't save it.  Instead we send an HTTP 422
    # Unprocessable Entity response.  In all other cases, we silently
    # remove the bad messages, save the batch as valid, and send an
    # HTTP 201 Created response.  Note that the HL7 protocol does not
    # provide for ACK^R01^ACK messages in response to message batches.
    # Note also that the HL7::Message.parse_batch method will raise an
    # exception if the batch is empty; non-validating children are
    # removed on creation (above); and AR will validate the remaining
    # children when it validates this batch.  Here we reject any batch
    # with no remaining valid messages, i.e. any batch with all invalid
    # messages.
    record_error(:invalid_message_batch) if staged_messages.empty?
  end

  def message_removed(staged_message)
    destroy if staged_messages.empty?
  end

  # There is no batch UI at the moment, and no provision for returning
  # a descriptive error to the user when batch posts fail.  We at least
  # log errors here.
  def record_error(*args)
    errmsg = args && args.first
    attribute = (args && args.second) || :hl7_message

    logger.error(errors.add(attribute, errmsg).last)
  end
end
