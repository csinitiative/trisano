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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MessageBatch do
  it 'should be invalid if all messages in the batch are invalid' do
    batch = MessageBatch.new :hl7_message =>
      HL7MESSAGES[:realm_bad_batch]
    batch.should_not be_valid
  end

  it 'should be valid if any message in the batch is valid' do
    batch1 = MessageBatch.create :hl7_message =>
      unique_messages(HL7MESSAGES[:realm_batch])

    batch1.should be_valid
    batch1.staged_messages.count.should == 2

    # :realm_batch_one_bad has two messages, one of which does not validate
    batch2 = MessageBatch.create :hl7_message =>
      HL7MESSAGES[:realm_batch_one_bad]
    batch2.should be_valid
    batch2.staged_messages.count.should == 1
  end

  it 'should delete itself once its children are removed' do
    batch = MessageBatch.create :hl7_message =>
      HL7MESSAGES[:realm_batch_one_bad]
    batch.should be_valid
    batch.staged_messages.count.should == 1

    batch.staged_messages.first.destroy
    lambda do
      MessageBatch.find batch.id
    end.should raise_exception
  end

  def unique_messages(message)
    message = HL7::Message.new(message)
    message[:MSH].each {|m| m.message_control_id = rand(1000) + Time.now.to_i }
    message.to_hl7
  end
end
