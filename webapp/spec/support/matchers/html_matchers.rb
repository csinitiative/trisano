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

        def initialize(content)
          if content.nil?
            raise ArgumentError, "must pass content or use 'has_blank_option' matcher"
          end
          @content = content
        end

        def matches?(document)
          false if document.nil?
          nodes = nodes_as_strings(document)
          nodes.any? do |html|
            doc = parse(html)
            doc.xpath("//option[normalize-space(text())='#{@content}']").size > 0
          end
        end

        def failure_message_for_should
          "option '#@content' was not found"
        end

        def failure_message_for_should_not
          "did not expect to find option '#@content'"
        end
      end

      def have_option(expected)
        HaveOption.new(expected)
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



