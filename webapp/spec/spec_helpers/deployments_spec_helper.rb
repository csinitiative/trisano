module DeploymentsSpecHelper

  def given_plugin_symlink(name)
    Dir.expects(:[]).with(Deployment.trisano_extensions).returns([plugin_symlink(name)])
    File.expects(:symlink?).with(plugin_symlink(name)).returns(true)
  end

  def given_no_plugin_symlink(plugin_name)
    file = plugin_symlink(plugin_name)
    File.expects(:exists?).with(file).returns(false)
  end

  def given_app_deployment(deployment, options = {})
    f = project_deployment(deployment)
    File.stubs(:exists?).with(f).returns(false)
    IO.expects(:read).with(project_descriptor(deployment)).returns(options.to_yaml)
  end

  def given_other_deployment(deployment, options = {})
    f = other_project_deployment(deployment)
    File.stubs(:exists?).with(f).returns(true)
    IO.expects(:read).with(other_project_descriptor(deployment)).returns(options.to_yaml)
  end

  def given_plugin(name)
    File.expects(:exists?).with(expanded_plugin_path(name)).returns(true)
  end

  def given_other_project_plugin(name)
    File.stubs(:exists?).with(expanded_other_project_plugin_path(name)).returns(true)
  end

  def given_other_project_plugin_js(name)
    File.expects(:exists?).with(expanded_other_project_plugin_js_path(name)).returns(true)
  end

  def given_other_project_dir(name)
    File.expects(:exists?).with(expanded_other_project_path(name)).returns(true)
  end

  def given_no_trisano_plugin_dir
    File.expects(:exists?).with(vendor_trisano_dir).returns(false)
  end

  def given_vendor_trisano_exists
    File.expects(:exists?).with(vendor_trisano_dir).returns(true)
  end

  def given_no_installer_link
    File.expects(:exists?).with(installer_symlink).returns(false)
  end

  def given_installer_symlink
    File.expects(:exists?).with(installer_symlink).returns(true)
    File.expects(:symlink?).with(installer_symlink).returns(true)
  end

  def given_ext_javascript_symlink(link_name)
    Dir.expects(:[]).with(File.join(Deployment.ext_javascripts, '*')).returns(ext_javascript_symlink(link_name))
    File.expects(:symlink?).with(ext_javascript_symlink(link_name)).returns(true)
  end

  def given_no_ext_javascript_dir
    File.expects(:exists?).with(Deployment.ext_javascripts).returns(false)
  end

  def given_ext_javascript_dir
    File.expects(:exists?).with(Deployment.ext_javascripts).returns(true)
  end

  def ext_javascript_symlink(link_name)
    File.join(RAILS_ROOT, 'public', 'javascripts', 'ext', link_name)
  end

  def plugin_symlink(plugin_name)
    File.join(vendor_trisano_dir, plugin_name)
  end

  def installer_symlink
    File.expand_path(File.join(RAILS_ROOT, '../install'))
  end

  def plugin_path(name)
    RAILS_ROOT + "/../plugins/" + name
  end

  def expanded_plugin_path(name)
    File.expand_path(plugin_path(name))
  end

  def other_project_plugin_path(name)
    File.join(other_project_path('plugins'), name)
  end

  def other_project_path(name)
    File.expand_path(File.join(RAILS_ROOT, "/../../otherproject/", name))
  end

  def expanded_other_project_plugin_path(name)
    File.expand_path(other_project_plugin_path(name))
  end

  def expanded_other_project_path(name)
    File.expand_path(other_project_path(name))
  end

  def expanded_other_project_plugin_js_path(name)
    File.join(expanded_other_project_plugin_path(name), 'public', 'javascripts')
  end

  def other_project_deployment(name)
    File.expand_path(File.join(other_project_path('deployments'), name))
  end

  def other_project_descriptor(deployment)
    File.expand_path(other_project_deployment(deployment) + "/descriptor.yml")
  end

  def project_deployment(name)
    RAILS_ROOT + "/../deployments/" + name
  end

  def project_descriptor(deployment)
    File.expand_path(project_deployment(deployment) + "/descriptor.yml")
  end

  def vendor_trisano_dir
    File.expand_path(File.join(RAILS_ROOT, 'vendor', 'trisano'))
  end
end
