#require 'mocha'

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
    File.expects(:exists?).with(expanded_other_project_plugin_path(name)).returns(true)
  end

  def plugin_symlink(plugin_name)
    RAILS_ROOT + "/vendor/trisano/" + plugin_name
  end

  def plugin_path(name)
    RAILS_ROOT + "/../plugins/" + name
  end

  def expanded_plugin_path(name)
    File.expand_path(plugin_path(name))
  end

  def other_project_plugin_path(name)
    RAILS_ROOT + "/../../otherproject/plugins/" + name
  end

  def expanded_other_project_plugin_path(name)
    File.expand_path(other_project_plugin_path(name))
  end

  def other_project_deployment(name)
    RAILS_ROOT + "/../../otherproject/deployments/" + name
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
end
