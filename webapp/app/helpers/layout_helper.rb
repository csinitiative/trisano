# -*- coding: utf-8 -*-


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

module LayoutHelper
  extensible_helper

  def render_footer
    result = ""

    result << "<div class='footlogo'>"
    result << image_tag("foot.png", :border => 0)
    result << "</div>"
    result << "<div class='foottext'>"
    result << "<div class='top'>"
    result << "<a href='https://wiki.csinitiative.com/display/tri/TriSano+-+2.5RC1+Release+Notes'>#{t('trisano_ce')}</a>"
    result << "</div>"
    result << "<div class='bottom'>"
    result << "<a href='http://www.trisano.org/collaborate/'>#{t('collaborate')}</a>"
    result << "&nbsp;|&nbsp;"
    result << "#{t('user_feedback')} (<a href='http://groups.google.com/group/trisano-user'>#{t('web')}</a>, <a href='mailto:trisano-user@googlegroups.com'>#{t 'email'}</a>)"
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
    when :en
      javascript_include_tag("translations_en")
    when :test
      javascript_include_tag("ext/trisano_locales_test/translations_test")
    else
      locale = I18n.locale.to_s
      javascript_include_tag("ext/trisano_#{locale}/translations_#{locale}")
    end
  end

  def render_main_logo
    returning "" do |result|
      result << '<div class="horiz">'
      result << link_to(
        image_tag(main_logo_path, :border => 0),
        home_path, :id => 'logo')
      result << '</div>'
    end
  end

  def main_logo_path
    "logo.png"
  end

  def top_nav
    top_nav = Trisano::TopNav.new
    if User.current_user
      case_management_menu_items(top_nav.add_child(:case_management))
      entity_management_menu_items(top_nav.add_child(:entity_management))
      system_management_menu_items(top_nav.add_child(:system_management))
      tools_menu_items(top_nav.add_child(:tools))
    end
    top_nav
  end

  def case_management_menu_items(menu)
    user = User.current_user
    menu.add_child(:new_cmr, event_search_cmrs_path) if user.is_entitled_to?(:create_event)
    menu.add_child(:events, cmrs_path) if user.is_entitled_to?(:view_event)
    menu.add_child(:staging_area, staged_messages_path) if user.is_entitled_to?(:manage_staged_message, :write_staged_message)
  end

  def entity_management_menu_items(menu)
    if User.current_user.is_entitled_to? :manage_entities
      menu.add_child(:people, people_path)
      menu.add_child(:places, places_path)
    end
  end

  def system_management_menu_items(menu)
    menu.add_child(:admin, admin_path) if User.current_user.is_admin?
  end

  def tools_menu_items(menu)
    user = User.current_user
    menu.add_child(:avr, config_option(:bi_server_url), :popup => true) if user.is_entitled_to? :access_avr
    menu.add_child(:search, search_cmrs_path) if user.is_entitled_to? :view_event
    menu.add_child(:settings, settings_path)
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
