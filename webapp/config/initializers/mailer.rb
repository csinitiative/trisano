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
