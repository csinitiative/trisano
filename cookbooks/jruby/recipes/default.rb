jruby = node[:jruby]

bash "Extract JRuby" do
  cwd jruby[:untar]
  code "tar -xzf #{jruby[:file]}"
  action :nothing
end

remote_file jruby[:file] do
  source   jruby[:link]
  checksum jruby[:sha]
  notifies :run, resources(:bash => "Extract JRuby"), :immediately
end

link jruby[:destination] do
  to jruby[:folder]
end

template "/etc/profile.d/jruby.sh" do
  mode 0755
  source "jruby.sh.erb"
  variables :destination => jruby[:destination]
end
