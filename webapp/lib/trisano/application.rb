module Trisano
  class Application
    attr_accessor :oid
    attr_accessor :bug_report_address
    attr_accessor :version_number

    def initialize
      @oid = %w{csi-trisano-ce 2.16.840.1.113883.4.434 ISO}
      @bug_report_address = 'trisano-user@googlegroups.com'
      @version_number = '3.0'
    end
  end

  def self.application
    @application ||= Application.new
  end
end
