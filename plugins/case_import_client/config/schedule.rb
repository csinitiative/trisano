env :PATH, ENV['PATH']
set :output, "/var/log/trisano/xsentinel_cron.log"

every 1.day, :at => '1:00am' do
  rake "whenever:xsentinel:run"
end
