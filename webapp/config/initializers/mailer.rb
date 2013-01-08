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
ActionMailer::Base.default_url_options[:host] ||= config_options[:host]
ActionMailer::Base.default_content_type = "text/html"

if ActionMailer::Base.delivery_method != :test && mailer_opts = config_options['mailer']
  if options = mailer_opts['smtp']
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = {
      :enable_starttls_auto => (options['enable_starttls_auto'] || false),
      :address => (options['address'] || 'localhost'),
      :port => (options['port'] || 25),
      :domain => (options['domain'] || 'localhost'),
      :authentication => (options['authentication'] || :plain).to_sym,
      :user_name => (options['user_name'] || nil),
      :password => (options['password'] || nil)
    }
  elsif options = mailer_opts['sendmail']
    ActionMailer::Base.delivery_method = :sendmail
    ActionMailer::Base.sendmail_settings = {
      :location => (options['location'] || '/usr/sbin/sendmail'),
      :arguments => (options['arguments'] || '-i -t')
    }
  else
    ActionMailer::Base.delivery_method = :test
  end
end
