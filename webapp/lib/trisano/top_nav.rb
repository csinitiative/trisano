module Trisano
  module MenuTreeRenderer
    include ActionView::Helpers::TagHelper

    def render
      if children.empty?
        ""
      else
        returning "" do |menus|
          menus << render_groups
          menus << render_submenus
          menus << render_javascript_menus
        end
      end
    end

    def render_groups
      returning "" do |results|
        results << tag('div', {:class => 'groups'}, true)
        results << render_links_and_rollovers
        results << '</div>'
      end
    end

    def render_links_and_rollovers
      children.map do |child|
        child.render_name if child.renderable?
      end.compact.join("&nbsp;|&nbsp;")
    end

    def render_submenus
      returning "" do |r|
        r << '<div id="submenu">&nbsp;</div>'
        children.each do |child|
          r << tag('span', {:class => 'submenu-content', :id => child.submenu_id}, true)
          r << child.render_links_and_rollovers
          r << "</span>"
        end
      end
    end

    def render_javascript_menus
      returning "" do |results|
        results << tag('script', {:type => 'text/javascript'}, true)
        results << "//<![CDATA[\n"
        results << children.map(&:javascript_menu).join("\n")
        results << "//]]>\n"
        results << "</script>"
      end
    end

    def render_name
      options = {:id => group_id, :href => link}
      convert_options_to_link_options!
      options.merge! @options if @options
      returning "" do |a|
        a << tag('a', options, true)
        a << name
        a << '</a>'
      end
    end

    def javascript_menu
      return "" unless renderable?
      returning "" do |js|
        js << "$('#{group_id}').observe('mouseover', function() { "
        js << "$('submenu').innerHTML = $('#{submenu_id}').innerHTML; "
        js << "});"
      end
    end

    def convert_options_to_link_options!
      @options ||= {}
      if @options.delete(:popup)
        @options[:target] = '_blank'
      end
    end

    def renderable?
      @link || !children.empty?
    end

  end

  class MenuNode
    include MenuTreeRenderer

    def initialize(name, *link_and_options)
      @options = link_and_options.extract_options!
      @name = name
      @link = link_and_options.first
    end

    def add_child(name, *link_and_options)
      menu_node = MenuNode.new(name, *link_and_options)
      children << menu_node
      menu_node
    end

    def children
      @menu_items ||= []
    end

    def last_child
      @menu_items[-1]
    end

    def name
      return unless @name
      I18n.t(@name)
    end

    def link
      @link || "#"
    end

    def group_id
      return unless @name
      "#{@name.to_s}_group"
    end

    def submenu_id
      return unless @name
      "#{@name.to_s}_submenu"
    end

  end

  class TopNav < MenuNode
    def initialize; end
  end

end
