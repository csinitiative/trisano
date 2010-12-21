default[:jruby][:version]      = "1.4.0"
default[:jruby][:sha]          = "775f79423337903f1f41d23c8ab3fa35bfaf4e915d44c6244ad983394ef14406"
default[:jruby][:src]          = "/usr/local/src"
default[:jruby][:file]         = "#{jruby[:src]}/jruby-bin-#{jruby[:version]}.tar.gz"
default[:jruby][:link]         = "http://jruby.kenai.com/downloads/#{jruby[:version]}/jruby-bin-#{jruby[:version]}.tar.gz"
default[:jruby][:untar]        = "/usr/local"
default[:jruby][:folder]       = "#{jruby[:untar]}/jruby-#{jruby[:version]}"
default[:jruby][:destination]  = "/usr/local/jruby"