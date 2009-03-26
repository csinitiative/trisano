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

  module Workflow
    class << self
      def included(recipient)
        recipient.instance_eval do
          def workflow(&proc)
            @states = {}
            @ordered_states = []
            proc.call if block_given?
          end

          def states
            @states
          end

          def ordered_states
            @ordered_states
          end

          def state(name, &proc)
            s = Routing::State.new(self, &proc)
            states[name] = s
            ordered_states << s
            s
          end

          def action_phrases_for(*state_names)
            state_names.collect do |state_name|
              if states[state_name].try(:action_phrase)
                OpenStruct.new(:phrase => states[state_name].action_phrase, 
                               :state => state_name)
              end
            end.compact
          end

          def get_state_keys
            states.keys
          end

          def get_states_and_descriptions
            ordered_states.map do |state| 
              OpenStruct.new(:state => state.state_code, 
                             :description => state.description)
            end
          end
        end

        recipient.class_eval do
          # not the best home for this, but it keeps all the state
          # stuff together.
          def current_state
            if self.respond_to?(:event_status)
              self.class.states.try(:[], self.event_status)
            end
          end
        end
                              
      end

    end
  end

  class State
    attr_accessor :required_privilege,
                  :action_phrase,
                  :transitions,
                  :state_code,
                  :description,
                  :note_text

    def initialize(state_holder, &proc)
      @state_holder = state_holder
      @transitions = []
      proc.call(self) if block_given?
    end

    def allows_transition_to?(proposed_state)
      transitions.include?(proposed_state)
    end

    # returns transitions for this state if they have action
    # phrases. The block gives caller a chance to reject any of these
    # states (based on privileges and what not).
    def renderable_transitions(&block)
      transitions.collect do |transition|
        transition_state = @state_holder.states[transition]
        if transition_state.action_phrase
          transition_state unless block_given? && !yield(transition_state)
        end
      end.compact
    end      
  end

end
