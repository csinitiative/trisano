# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
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

  def given_other_project_plugin_images(name)
    File.expects(:exists?).with(expanded_other_project_plugin_image_path(name)).returns(true)
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

  def given_no_cap_deploy_link
    File.expects(:exists?).with(cap_deploy_symlink).returns(false)
  end

  def given_installer_symlink
    File.expects(:exists?).with(installer_symlink).returns(true)
    File.expects(:symlink?).with(installer_symlink).returns(true)
  end

  def given_cap_deploy_symlink
    File.expects(:exists?).with(cap_deploy_symlink).returns(true)
    File.expects(:symlink?).with(cap_deploy_symlink).returns(true)
  end

  def given_ext_javascript_symlink(link_name)
    Dir.expects(:[]).with(File.join(Deployment.ext_javascripts, '*')).returns(ext_javascript_symlink(link_name))
    File.expects(:symlink?).with(ext_javascript_symlink(link_name)).returns(true)
  end

  def given_no_ext_javascript_dir
    File.expects(:exists?).with(Deployment.ext_javascripts).returns(false)
  end

  def given_no_ext_images_dir
    File.expects(:exists?).with(Deployment.ext_images).returns(false)
  end

  def given_ext_javascript_dir
    File.expects(:exists?).with(Deployment.ext_javascripts).returns(true)
  end

  def given_ext_images_dir
    File.expects(:exists?).with(Deployment.ext_images).returns(true)
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

  def cap_deploy_symlink
    File.expand_path(File.join(RAILS_ROOT, 'config/deploy'))
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

  def expanded_other_project_plugin_image_path(name)
    File.join(expanded_other_project_plugin_path(name), 'public', 'images')
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
