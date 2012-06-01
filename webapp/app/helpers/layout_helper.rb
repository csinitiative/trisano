# -*- coding: utf-8 -*-


# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

require 'trisano'

module LayoutHelper
  include Trisano
  extensible_helper

  def render_footer
    result = ""

    managed_footer = managed_content('footer')

    if !managed_footer.blank?
      result << managed_footer
      result << "<hr/>"
    end

    result << "<div class='footlogo'>"
    result << image_tag("foot.png", :border => 0)
    result << "</div>"
    result << "<div class='foottext'>"
    result << "<div class='top'>"
    result << link_to_release_notes(application.actual_name)
    result << "</div>"
    result << "<div class='bottom'>"
    result << "<a href='http://www.trisano.org/collaborate/'>#{t('collaborate')}</a>"
    result << "&nbsp;|&nbsp;"
    result << "#{t('user_feedback')} (<a href='http://groups.google.com/group/trisano-user'>#{t('web')}</a>, <a href='mailto:#{application.bug_report_address}'>#{t 'email'}</a>)"
    result << "&nbsp;|&nbsp;"
    result << "<a href='http://www.trisano.org'>#{t('about')}</a>"
    result << "&nbsp;|&nbsp;"
    result << "<a href='http://www.trisano.org/collaborate/licenses/'>#{t('license')}</a>"
    result << "&nbsp;|&nbsp;"
    result << "<a href='http://github.com/csinitiative/trisano/tree/master'>#{t('source')}</a>"
    result << "</div>"
    result << "<div class='bottom'>"
    result << t('copyright')
    result << "</div>"
    result << "</div>"

    result
  end

  def link_to_release_notes text
    link_to text, release_notes_url
  end

  def release_notes_url
    "https://wiki.csinitiative.com/display/#{application.subscription_space}/TriSano+-+#{application.version_number}+Release+Notes"
  end

  # some javascript just needs to be in the hosted page
  def embedded_javascripts
    <<-JS
      <script type="text/javascript">
        function loadScript(src) {
          var script = document.createElement('script');
          script.type = 'text/javascript';
          script.src  = src
          document.body.appendChild(script);
        }
      </script>
    JS
  end

  def translations_js
    case I18n.locale
    when :test
      javascript_include_tag("ext/trisano_locales_test/translations_test")
    else
      locale = I18n.locale.to_s
      javascript_include_tag("ext/trisano_#{locale}/translations_#{locale}")
    end
  end

  def render_small_logo
    image_tag(small_logo_path, :border => 0, :id => 'logo', :height => "60px", :width => "59px")
  end
  
  def render_main_logo
    returning "" do |result|
      result << '<div class="horiz" id="logo-container">'
      result << image_tag(main_logo_path, :border => 0, :id => 'logo')
      result << '</div>'
    end
  end

  def small_logo_path
    'logo_small.png'
  end

  def main_logo_path
    logo = Logo.last

    if logo.nil?
      'logo.png'
    else
      logo_path(logo)
    end
  end

  def render_patient_summary
    if defined?(@event) and !@event.new_record? and @event.patient
      output = "#{@event.patient.last_comma_first} (#{record_number_without_phone})"
      output << " DOB: #{@event.patient.birth_date.strftime("%m/%d/%Y")}" if @event.patient.birth_date.present?
      output << "<br/>#{@event.disease_name}" if @event.disease_name.present?
      output << " (#{@event.state_description})" if @event.state.present?
    end
  end

  def record_number_without_phone
    # Because mobile OSes and browser plugins like Skype
    # detect 10 digit numbers as phone numbers, it seems the best
    # way to prevent this type of detection is by putting invisible
    # span tags in the number. 
    #
    # Sadly, this does not stop the Google Voice plugin when you double
    # click on the number. 
    arr = @event.record_number.chars.to_a
    arr.insert(1, "<span>")
    arr.insert(4, "<span>")
    arr.insert(6, "</span>")
    arr << "</span>"
    arr.join
  end

  def render_main_menu
    links = main_menu_items.collect do |item|
      item[:options] ||= {}
      text = item[:t] ? t(*item[:t]) : item[:text]
      link_to(text, item[:link], item[:options])
    end
    links.join(" | ")
  end

  def main_menu_items
    return MenuArray.new unless user = User.current_user
    returning MenuArray.new do |items|
      items << {:link => home_path, :t => :dashboard}
      if user.is_entitled_to? :create_event
        items << {:link => event_search_cmrs_path, :t => :new_cmr}
        items << {:link => event_search_aes_path, :t => :new_ae}
      end
      if user.is_entitled_to? :manage_staged_message, :write_staged_message
        items << {
          :link => staged_messages_path,
          :t => :staging_area,
          :options => {:rel => "http://trisano.org/relation/staged_messages"}}
      end
      if user.is_entitled_to? :view_event
        items << {:link => cmrs_path_with_defaults, :t => :events}
        items << {:link => search_cmrs_path, :t => :search}
      end
      if user.is_entitled_to? :manage_entities
        items << {:link => people_path, :t => :people}
        items << {:link => places_path, :t => :places}
      end
      if user.is_entitled_to? :access_avr
        items << {
          :link => config_option(:bi_server_url),
          :t => :avr,
          :options => {:popup => true}}
      end
      if user.is_admin?
        items << {:link => admin_path, :t => :admin}
      end
      items << {:link => settings_path, :t => :settings}
      if application.has_help?
        items << {:link => help_url, :t => :help, :options => {:popup => true}}
      end
    end
  end

  def help_url
    unless help_url = config_option(:help_url)
      help_url = "https://wiki.csinitiative.com/display/#{application.subscription_space}/Help"
    end
    help_url
  end

  def render_user_tools(user)
    if allow_user_switching?
      change_user_url = url_for(:controller => :events, :action => :change_user)
      returning "" do |result|
        result << form_tag(change_user_url, :id => 'switch_user', :style => 'display: inline')
        result << "<span id='user_name'>#{current_user_name}:</span>"
        result << select_tag("user_id", options_for_user_select(user), :onchange => 'this.form.submit()', :style => 'display: inline')
        result << "</form>"
      end
    else
      current_user_name
    end
  end

  def allow_user_switching?
    config_option(:auth_allow_user_switch) and not config_option(:auth_allow_user_switch_hidden)
  end

  def options_for_user_select(user)
    users = User.all(:order => 'user_name').map {|u| [u.user_name, u.uid]}
    options_for_select(users, user.uid)
  end
end
