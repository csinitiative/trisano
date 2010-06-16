namespace :trisano do

  namespace :perinatal_hep_b do

    desc "Run specs for Perinatal Hep B"
    Spec::Rake::SpecTask.new(:spec => [:spec_banner, 'db:test:prepare']) do |t|
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList[File.join(File.dirname(__FILE__), '..', 'spec')]
    end

    task :spec_banner do
      puts
      puts "*** Running Perinatal Hep B specs ***"
    end

  end

end

task :spec do |t|
  Rake::Task['trisano:perinatal_hep_b:spec'].invoke
end
