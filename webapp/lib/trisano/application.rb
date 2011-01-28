require 'singleton'

module Trisano
  class Application
    include Singleton

    attr_accessor :oid
    attr_accessor :bug_report_address
    attr_writer   :subscriber

    # i18n key for then application name
    attr_accessor :actual_name_key

    def initialize
      @oid = %w{csi-trisano-ce 2.16.840.1.113883.4.434 ISO}
      @bug_report_address = 'trisano-user@googlegroups.com'
      @subscriber = false
      @actual_name_key = :trisano_ce
    end

    def actual_name
      @actual_name ||= "#{I18n.t(actual_name_key)} #{version_number}"
    end

    def version_number
      @version_number ||= Trisano::VERSION.join('.')
    end

    def subscription_space
     sub_space = "tri"
     sub_space << Trisano::VERSION[0,2].join if subscriber?
     sub_space
    end

    def subscriber?
      @subscriber
    end

    def has_help?
      subscriber? || config_option('help_url')
    end
  end

  def self.application
    Application.instance
  end

  def application
    Application.instance
  end
end
