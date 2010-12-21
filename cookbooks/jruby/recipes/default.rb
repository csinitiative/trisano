
jruby = node[:jruby]

bash "Untar JRuby" do
  cwd jruby[:untar]
  code "tar xzf #{jruby[:file]}"
  action :nothing
end

# Download jruby
remote_file jruby[:file] do
  source   jruby[:link]
  checksum jruby[:sha]
  notifies :run, resources(:bash => "Untar JRuby"), :immediately
end

link jruby[:destination] do
  to jruby[:folder]
end

template "/etc/profile.d/jruby.sh" do
  mode 0755
  source "jruby.sh.erb"
  variables :destination => jruby[:destination]
end
