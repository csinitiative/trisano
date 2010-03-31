require File.dirname(__FILE__) + '/../../spec_helper'

include Trisano

describe TopNav do
  include HtmlSpecHelper

  before do
    @top_nav = TopNav.new
  end

  describe "with no menus" do
    it "renders an empty string" do
      @top_nav.render.should == ""
    end
  end

  describe "adding menus" do
    before do
      @menu = @top_nav.add_child(:case_management, "http://localhost")
    end

    it "renders menu title" do
      parse_html(@top_nav.render).css("a").inner_text.should =~ /Cases/
    end

    it "renders several menu titles" do
      @top_nav.add_child(:entity_management, "http://localhost")
      node_list = parse_html(@top_nav.render).css("a")
      node_list.inner_text.should =~ /Cases/i
      node_list.inner_text.should =~ /Entities/i
    end

    it "renders submenus in javascript" do
      @menu.add_child(:events, 'http://localhost')
      node = parse_html(@top_nav.render)
      node.css("a").inner_text.should =~ /events/i
      node.xpath("//span[@id='case_management_submenu']").size.should == 1
    end
  end
end
