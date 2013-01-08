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
module Trisano
  module HTML
    module Matchers

      class Base
        private

        def nodes_as_strings(response_or_nodes)
          case
          when response_or_nodes.nil?
            return []
          when response_or_nodes.respond_to?(:body)
            return [response_or_nodes.body]
          else
            return response_or_nodes.map(&:to_s)
          end
        end

        def parse(text)
          Nokogiri::HTML.parse(text)
        end

      end

      class Css
        def initialize(css)
          @css = css
        end

        def matches?(text)
          doc = Nokogiri::XML(text)
          @node_count = doc.css(@css, supported_namespaces).size
          @node_count > 0
        end

        def failure_message_for_should
          "expected at least 1 node for css <#{@css}>. Found 0."
        end

        def failure_message_for_should_not
          "expected 0 nodes for css <#{@css}>. Found #{@node_count}"
        end

        def supported_namespaces
          {'atom' => "http://www.w3.org/2005/Atom"}
        end
      end

      def have_css(css)
        Css.new(css)
      end

      class BlankOption < Base
        def matches?(document)
          return false if document.nil?
          nodes = nodes_as_strings(document)
          nodes.any? do |html|
            parse(html).css("option:empty").size > 0
          end
        end

        def failure_message_for_should
          "expected a blank option, but none was found"
        end

        def failure_message_for_should_not
          "did not expect a blank option, but at least one was found"
        end

      end

      def have_blank_option
        BlankOption.new
      end

      class HaveOption < Base

        def initialize(options)
          @options = (options || {}).stringify_keys
        end

        def matches?(document)
          false if document.nil?
          nodes = nodes_as_strings(document)
          nodes.any? do |html|
            doc = parse(html)
            doc.xpath(generate_xpath).size > 0
          end
        end

        def failure_message_for_should
          "option w/ predicates [#{xpath_predicates}] was not found"
        end

        def failure_message_for_should_not
          "did not expect to find option w/ predicates [#{xpath_predicates}]"
        end

        private

        def generate_xpath
          "//option[#{xpath_predicates}]"
        end

        def xpath_predicates
          @options.map do |key, value|
            case key
            when 'text'
              "normalize-space(text())='#{value}'"
            when 'selected'
              value ? "@selected" : "not(@selected)"
            else
              value.nil? ? "@#{key}" : "@#{key}='#{value}'"
            end
          end.join(' and ')
        end

      end

      def have_option(options)
        HaveOption.new(options)
      end

      class HaveLabledCheckBox < Base
        def initialize(content)
          if content.nil?
            raise ArgumentError, "must pass check box label text"
          end
          @content = content
        end

        def matches?(document)
          @document = document
          false if document.nil?
          nodes = nodes_as_strings(document)
          nodes.any? do |html|
            doc = parse(html)
            inputs = doc.css("label input[type='checkbox']")
            inputs.any? { |i| i.xpath('..').text().strip() == @content }
          end
        end

        def failure_message
          "expected #{@document.to_s} to have labeled checkbox #{@content}"
        end
      end

      def have_labeled_check_box(expected)
        HaveLabledCheckBox.new(expected)
      end

    end
  end
end



