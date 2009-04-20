# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

class Attachment < ActiveRecord::Base

  belongs_to :event

  class << self
    def category_array
      [["Correspondence", "correspondence"], ["Laboratory results", "lab"], ["Letter", "letter"], ["X-ray", "x-ray"]]
    end

    def valid_categories
      @valid_categories ||= category_array.map { |category| category.last }
    end
  end
  
  has_attachment :storage => :db_file,
    :size => (1..10.megabyte),
    :content_type => ['application/pdf',
    'application/msword',
    'application/vnd.oasis.opendocument.text',
    'application/vnd.ms-excel',
    'application/x-msexcel',
    'application/ms-excel',
    'application/vnd.oasis.opendocument.spreadsheet',
    'image/jpg',
    'image/jpeg',
    'image/gif',
    'image/png',
    'image/tiff',
    'image/bmp',
    'text/plain'
  ]

  validates_attachment :size         => "The file you uploaded was larger than the maximum size of 10MB"
  validates_inclusion_of :category, :in => self.valid_categories, :message => "is not valid", :allow_blank => true
  
  attr_accessible :event_id, :category

end
