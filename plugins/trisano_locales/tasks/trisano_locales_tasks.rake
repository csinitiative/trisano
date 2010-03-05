# desc "Explaining what the task does"
# task :trisano_locales do
#   # Task goes here
# end

namespace :trisano do
  namespace :dev do

    desc "Load locale privileges"
    task :load_defaults do
      load_defaults = File.join(File.dirname(__FILE__), "..", "script", "load_defaults.rb")
      ruby "#{RAILS_ROOT}/script/runner #{load_defaults}"
    end

    desc "Prep cucumber for default locale changes"
    task :feature_prep do
      load_defaults = File.join(File.dirname(__FILE__), "..", "script", "load_defaults.rb")
      ruby "#{RAILS_ROOT}/script/runner -e test #{load_defaults}"
    end
  end

end
