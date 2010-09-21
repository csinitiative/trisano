class MessageBatch < ActiveRecord::Base
  has_many :staged_messages, :dependent => :nullify

  attr_accessor :hl7_message

  def validate
    # parse outer batch envelope
    # retrieve each nested, raw HL7 message
    # pass it to build_staged_message
  end
end
