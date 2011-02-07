module Trisano
  module CorePathCallable
    def call_chain
      if core_path
        path = core_path.scan(/\[([^\[\]]*)\]/).collect{|group| group[0].gsub(/_id$/, '')}
      end
    end
  end
end
