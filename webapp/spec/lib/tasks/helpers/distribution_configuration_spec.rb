require 'spec_helper'
require 'tasks/helpers'

module Tasks::Helpers

  describe DistributionConfiguration do
    before do
      @config = DistributionConfiguration.new({
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

end
