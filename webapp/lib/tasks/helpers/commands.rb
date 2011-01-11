module Tasks
  module Helpers
    module Commands

      def runner *args, &block
        ruby rakefile_dir('script/runner'), *args, &block
      end

      def rake *args, &block
        ruby "-S", "rake", *args, &block
      end

    end 
  end
end
