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
