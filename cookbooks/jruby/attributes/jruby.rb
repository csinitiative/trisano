default[:jruby][:version]      = "1.5.5"
default[:jruby][:sha]          = "6f4c96e91727d42dedc6be63ee9da959e60aa817"
default[:jruby][:src]          = "/usr/local/src"
default[:jruby][:file]         = "#{jruby[:src]}/jruby-bin-#{jruby[:version]}.tar.gz"
default[:jruby][:link]         = "http://jruby.org.s3.amazonaws.com/downloads/#{jruby[:version]}/jruby-bin-#{jruby[:version]}.tar.gz"
default[:jruby][:untar]        = "/usr/local"
default[:jruby][:folder]       = "#{jruby[:untar]}/jruby-#{jruby[:version]}"
default[:jruby][:destination]  = "/usr/local/jruby"

