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

class EmailAddress < ActiveRecord::Base
  include Trisano::Repeater
  before_validation :strip_whitespace
  belongs_to :owner, :polymorphic => true

  
  # We have commented this out because now we can accept nested attributes for this
  # which may include form fields. Thus, we may want to record form data and not an email
  #validates_presence_of :email_address
  # The above also requires the inclusion of :allow_blank => true below
  validates_format_of :email_address, :with => /@/, :message => I18n.t(:invalid_email_format), :allow_blank => true

  #validates_uniqueness_of :email_address, :case_sensitive => false

  def xml_fields
    [:email_address]
  end

  private

  def strip_whitespace
    email_address.strip! if email_address
  end
end

