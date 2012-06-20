# Copyright (C) 2009, 2010, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition..

if (config_option(:auth_src_env) || config_option(:auth_src_header)).nil? || RAILS_ENV == "feature"
  I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '**', '*.{rb,yml}')]
  require 'trisano_auth'
end
