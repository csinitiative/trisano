# desc "Explaining what the task does"
# task :trisano_locales_test do
#   # Task goes here
# end

# locales tests are here, because they rely on test translations
namespace :trisano do
  namespace :locales_test do
    task :spec => [:spec_banner, 'db:test:prepare']
    desc "Runs specs fromt the locales test plugin"
    Spec::Rake::SpecTask.new(:spec) do |t|
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList[File.join(File.dirname(__FILE__), '..', 'spec')]
    end

    task :spec_banner do
      puts
      puts "*** Running locales specs ***"
    end
  end
end

task :spec do |t|
  Rake::Task['trisano:locales_test:spec'].invoke
end
