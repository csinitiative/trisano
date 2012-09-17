namespace :whenever do
  namespace :xsentinel do
    desc "Update XSentinel job config"
    task "update" => :environment do
      `whenever -f #{RAILS_ROOT}/vendor/trisano/case_import_client/config/schedule.rb --update-crontab xsentinel`
    end

    desc "Run XSentinel job"
    task "run" => :environment do
      CaseImportClient.start_import
    end
  end
end