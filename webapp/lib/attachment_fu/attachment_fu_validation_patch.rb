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

# Monkey patch to improve attachment_fu validation error messaging. Licensed under WTFPL.
#
# See:
# http://toolmantim.com/articles/rollin_your_own_attachment_fu_messages_evil_twin_stylee


Technoweenie::AttachmentFu::InstanceMethods.module_eval do
  protected
  def attachment_valid?
    if self.filename.nil?
      errors.add_to_base attachment_validation_options[:empty]
      return
    end
    [:content_type, :size].each do |option|
      if attachment_validation_options[option] && attachment_options[option] && !attachment_options[option].include?(self.send(option))
        errors.add_to_base attachment_validation_options[option]
      end
    end
  end
end

Technoweenie::AttachmentFu::ClassMethods.module_eval do
  # Options:
  # *  <tt>:empty</tt> - Base error message when no file is uploaded. Default is "No file uploaded"
  # *  <tt>:content_type</tt> - Base error message when the uploaded file is not a valid content type.
  # *  <tt>:size</tt> - Base error message when the uploaded file is not a valid size.
  #
  # Example:
  #   validates_attachment :content_type => "The file you uploaded was not a JPEG, PNG or GIF",
  #                        :size         => "The image you uploaded was larger than the maximum size of 10MB"
  def validates_attachment(options={})
    options[:empty] ||= "No file uploaded"
    class_inheritable_accessor :attachment_validation_options
    self.attachment_validation_options = options
    validate :attachment_valid?
  end
end
