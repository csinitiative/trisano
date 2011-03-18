ActionMailer::Base.default_url_options[:host] ||= config_options[:host]
ActionMailer::Base.default_content_type = "text/html"

if ActionMailer::Base.delivery_method != :test
  mailer_options = config_options['mailer'] || {}
  if mailer_options == 'test'
    ActionMailer::Base.delivery_method = mailer.to_sym
  else
    mailer_options.each do |k, v|
      ActionMailer::Base.delivery_method = k
      ActionMailer::Base.send("#{k}_settings=", v.symbolize_keys)
    end
  end
end
