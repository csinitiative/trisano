desc 'Automatically run specs as related files change'
task 'spec:watchr' => 'db:test:prepare' do
  Kernel.exec('bundle exec watchr watchr/specs.rb')
end
