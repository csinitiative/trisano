# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

module ContactEventsHelper
  extensible_helper

  def contact_event_tabs
    event_tabs_for :contact_event
  end

  # Renders a reusable in-line contact search form.
  #
  # Options:
  #   * results_action: For in-line mulitples, use 'add', for
  #     links to the contact new/edit views, use 'new'
  #   * parent_id: The id of the parent event if applicable
  def contact_search_interface(options={}, &block)
    haml_tag(:input, :type => 'text', :id => 'contact_search_name')
    haml_concat(button_to_remote(t('search_button'), { :method => :get, :url => {:controller => "events", :action => 'contacts_search'}, :with => contact_search_with_option(options), :update => 'contact_search_results', :loading => "$('contact-search-spinner').show();", :complete => "$('contact-search-spinner').hide();" }, :id => "contact_search"))
    haml_concat(image_tag('redbox_spinner.gif', :id => 'contact-search-spinner', :style => "height: 16px; width: 16px; display: none;"))
    yield if block_given?
    haml_tag(:div, :id => 'contact_search_results')
  end

  def contact_edit_search_js
    <<-SCRIPT
    <script type='text/javascript'>
    $j(function() {
      $j('#new-contact-for-event').click(function() {
        $j("#contact-search").show();
      });

      $j('#close-contact-search').click(function() {
        $j("#contact-search").hide();
      });
    });
    </script>
    SCRIPT
  end

  private

  def contact_search_with_option(options)
    results_action = options[:results_action].blank? ? 'add' : options[:results_action].to_s
    parent_id = options[:parent_id].blank? ? nil : options[:parent_id].to_s
    with_option = "'name=' + $('contact_search_name').value + '&results_action=#{results_action.to_s}"
    with_option << "&parent_id=#{parent_id}" unless parent_id.nil?
    with_option << "'"
    return with_option
  end

end
