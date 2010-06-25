# Copyright (C) 2009, 2010, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition..

unless config_option(:auth_src_env) || config_option(:auth_src_header)
  I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '**', '*.{rb,yml}')]
  require 'trisano_auth'
end
