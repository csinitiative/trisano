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
require 'spec_helper'
require 'tasks/helpers'

module Tasks::Helpers

  describe Distribution do
    before do
      @config = Distribution.new({
        :priv_passwd => 'pr1v4t3'
      })
    end

    it "sets the $PGPASSWORD env variable" do
      ENV['PGPASSWORD'].should_not be_nil
    end

    context 'configuration rules' do
      %w{host port database postgres_dir priv_uname trisano_uname trisano_user_passwd environment basicauth min_runtime max_runtimes runtime_timeout}.each do |attr|
        it "require the #{attr} to be configured" do
          lambda { @config.send attr }.should raise_error
        end
      end
    end
  end

  context "#repo_root" do
    it "assumes the current root, if none is specified" do
      Distribution.repo_root.should == File.expand_path('..', RAILS_ROOT)
    end
  end

  context "#distro_war_file" do
    before do
      @config = Distribution.new :priv_passwd => 'pr1v4t3'
    end

    it "points to the war file location in the distro directory" do
      @config.distro_war_file.should == File.expand_path('../distro/trisano.war', RAILS_ROOT)
    end
  end

  context "#war_file" do
    before do
      @config = Distribution.new :priv_passwd => 'pr1v4t3'
    end

    it "points to the war file location in the webapp directory" do
      @config.war_file.should == File.expand_path('trisano.war', RAILS_ROOT)
    end
  end
end
