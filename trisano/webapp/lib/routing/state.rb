# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

module Routing

  class State

    class << self       
      def states
        @@states ||= {}
      end
    end
    
    def initialize(options = {})
      @options = options
    end

    def required_privilege
      @options[:priv_required]
    end

    def allows_transition_to?(proposed_state)
      @options[:transitions].include?(proposed_state)
    end

    def action_phrase
      @options[:action_phrase]
    end

    def transitions
      @options[:transitions] ||= []
    end

    def state_code
      @options[:state_code]
    end
    
    def description
      @options[:description]
    end

    def note_text
      @options[:note_text]
    end

    # returns transitions for this state if they have action
    # phrases. The block gives caller a chance to reject any of these
    # states (based on privileges and what not).
    def renderable_transitions(&block)
      transitions.collect do |transition|
        transition_state = Routing::State.states[transition]
        if transition_state.action_phrase
          transition_state unless block_given? && !yield(transition_state)
        end
      end.compact
    end      

  end

end
