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
# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
Mime::Type.register_alias "text/html", :print
Mime::Type.register_alias "text/plain", :dat
Mime::Type.register_alias "text/plain", :txt

Mime::Type.register("application/pdf",  :pdf)
Mime::Type.register('image/jpg', :jpg, ['image/jpeg'], ['jpeg'])
Mime::Type.register("image/gif",  :gif)
Mime::Type.register("image/png",  :png)
Mime::Type.register("image/tiff",  :tiff, [], ['tif'])
Mime::Type.register("application/msword", :doc)
Mime::Type.register("application/vnd.oasis.opendocument.text", :odt)
Mime::Type.register("application/vnd.ms-excel",  :xls, ['application/x-msexcel', 'application/ms-excel'])
Mime::Type.register("application/vnd.oasis.opendocument.spreadsheet",  :ods)
Mime::Type.register("image/bmp",  :bmp)

# http://wiki.hl7.org/index.php?title=Media-types_for_various_message_formats
# lists some other types for consideration:
#
# application/edi-hl7v2+xml - HL7v2 with XML encoding
# application/edi-hl7v3+xml - HL7v3 with XML encoding
#
# We don't currently handle XML posts, so we ignore these types.  The
# application/edi-hl7 type was rejected, but we'll continue to accept
# it for the moment.
Mime::Type.register("application/edi-hl7v2", :hl7, ["application/edi-hl7"])
