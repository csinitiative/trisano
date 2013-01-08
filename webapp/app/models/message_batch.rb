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
