class MessageBatch < ActiveRecord::Base
  has_many :staged_messages, :dependent => :nullify,
    :after_remove => :message_removed
  before_validation :remove_bad_children

  def validate
    # parse outer batch envelope
    # retrieve each nested, raw HL7 message
    # pass it to staged_messages.build

    # If we receive an empty batch or a batch with all invalid
    # messages, we don't save it.  Instead we send an HTTP 422
    # Unprocessable Entity response.  In all other cases, we silently
    # remove the bad messages (via the before_validation filter), save
    # the batch as valid, and send an HTTP 201 Created response.  Note
    # that the HL7 protocol does not provide for ACK^R01^ACK messages
    # in response to message batches.  Note also that non-validating
    # children are removed by the :remove_bad_children filter, and AR
    # will validate the remaining children when it validates this
    # batch.  Here we reject any batch with no remaining valid
    # messages.
    errors.add(:hl7_message, 'bad data') if staged_messages.empty?
  end

  def remove_bad_children
    @in_validation_filter = true
    staged_messages.each do |staged_message|
      staged_messages.delete(staged_message) unless staged_message.valid?
    end
    @in_validation_filter = false
    true # in case there are any other before_validation callbacks
  rescue
    @in_validation_filter = false
  end

  def message_removed(staged_message)
    return true if in_validation_filter
    destroy if staged_messages.empty?
  end

  private

  attr_accessor :in_validation_filter
end
