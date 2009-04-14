Webrat.configure do |config|
  config.mode = :rails
end

Cucumber::Rails.use_transactional_fixtures
