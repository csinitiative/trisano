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

module AttachmentsHelper

  def delete_attachment(attachment)
    link_to_remote("Delete", 
                   :url => event_attachment_path(attachment.event, attachment), :method => :delete,  
                   :confirm => 'Really delete attachment?',
                   :before => "$('attachment_#{attachment.id}_spinner').show();")
  end

  def attachment_spinner(attachment)
    image_tag('redbox_spinner.gif', 
              :alt => 'Working...', 
              :id => "attachment_#{attachment.id}_spinner", 
              :style => 'display: none;')
  end
end
