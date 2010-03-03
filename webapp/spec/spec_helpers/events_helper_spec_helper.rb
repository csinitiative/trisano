require RAILS_ROOT + '/spec/spec_helpers/html_spec_helper'

module EventsHelperSpecHelper
  include HtmlSpecHelper

  def assert_event_links(type, show_link, edit_link)
    event = Factory.create(type)
    login_as_super_user
    out = helper.show_and_edit_event_links(event)
    links = Nokogiri::HTML.parse(out)
    clean_nbsp(links.css("#show-event-#{event.id}").text).should == show_link
    clean_nbsp(links.css("#edit-event-#{event.id}").text).should == edit_link
  end
end
