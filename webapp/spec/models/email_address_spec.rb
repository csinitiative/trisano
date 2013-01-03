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

require 'spec_helper'

describe EmailAddress do
  context 'general' do
  # We have commented this out because now we can accept nested attributes for this
  # which may include form fields. Thus, we may want to record form data and not an email
  #  it { should validate_presence_of(:email_address) }
  #  it 'should not allow a blank e-mail address' do
  #    lambda { Factory :email_address, :email_address => '' }.should raise_error
  #  end


# Email addresses don't actually have to be unique
#    it 'should not allow duplicate e-mail addresses' do
#      lambda { 2.times { Factory :email_address, :email_address => 'user@example.com' } }.should raise_error
#    end
#
#    it 'should ignore case' do
#      Factory :email_address, :email_address => 'user@example.com'
#      lambda do
#        Factory :email_address, :email_address => 'USER@eXaMpLe.coM'
#      end.should raise_error
#    end
#
#    it 'should ignore leading and trailing whitespace' do
#      Factory :email_address, :email_address => 'user@example.com'
#      lambda do
#        Factory :email_address, :email_address => ' user@example.com '
#      end.should raise_error
#      Factory.build(:email_address, :email_address => ' user@example.com ').should_not be_valid
#    end

    it 'should not allow an invalid e-mail address' do
      lambda { Factory :email_address, :email_address => 'xyz' }.should raise_error
    end
  end

  context 'polymorphic owner association' do
    it 'can be associated with a user' do
      user = Factory :user
      lambda { user.email_addresses.build :email_address => 'user@example.com' }.should_not raise_error
      email = user.email_addresses.first
      email.owner_type.should == 'User'
      email.owner.should be_a(User)
    end

    it 'can be associated with an entity' do
      entity = Factory :place_entity
      lambda { entity.email_addresses.build :email_address => 'user@example.com' }.should_not raise_error
      email = entity.email_addresses.first
      email.owner_type.should == 'Entity'
      email.owner.should be_an(Entity)
    end
  end
end
