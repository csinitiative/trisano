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

module TreatmentsHelper

  def render_merge_treatment

    haml_tag(:form,  :action => url_for(:controller => 'treatments', :action => 'duplicates', :id => @treatment), :method => :post, :id => "merge_form") do
      haml_tag(:div, :id => 'merge_treatment') do
        haml_tag(:table, :class => 'list') do
          haml_concat "<tr><th class='forminformation'>#{t("merge_treatment")}</th><th></th></tr>"
          haml_concat "<tr>"
          haml_concat "<td class='forminformation'>"
          haml_concat "<div class='formname'>#{h @treatment.treatment_name}</div>"
          haml_concat "#{@treatment.active ? "Active" : "Inactive" }"
          haml_concat "</td>"
          haml_concat "<td>"
          haml_concat submit_tag(t("merge")) unless (@treatments.nil? || @treatments.empty?)
          haml_concat "&nbsp;&nbsp;&nbsp;"
          haml_concat "("

          unless (@treatments.nil? || @treatments.empty?)
            haml_concat "Select: "
            haml_concat link_to_function(t("all"), "$$('#merge_form input.merge_check_box').each(function(box){box.checked=true});return false;")
            haml_concat ",&nbsp;"
            haml_concat link_to_function(t("none"), "$$('#merge_form input.merge_check_box').each(function(box){box.checked=false});return false;")
            haml_concat ",&nbsp;"
          end

          haml_concat link_to(t("cancel"), treatments_path(:treatment_name => params[:treatment_name]))
          haml_concat ")"
          haml_concat "</td>"
          haml_concat "</tr>"
        end
      end

      haml_concat(yield) if block_given?
    end
  end

  def treatment_status(treatment)
    statuses = ""
    statuses << (treatment.active? ? t(:active) : t(:inactive))
    statuses << "&nbsp;#{t(:default)}" if treatment.default?
    statuses
  end

  def render_treatment_merge_actions(treatment)
    if current_page?(:action => :merge)
      check_box = check_box_tag('to_merge[]',
        treatment.id,
        false,
        :id => "to_merge_#{treatment.id}",
        :class => "merge_check_box")
      check_box << t("merge_into", :name => h(@treatment.treatment_name))
      haml_concat(check_box)
    else
      haml_concat(link_to t('merge'), { :controller => 'treatments', :action => 'merge', :id => treatment, :treatment_name => params[:treatment_name] }, :id => "merge_#{treatment.id}")
    end
  end

  def render_disease_treatments(treatments, options = {})
    options[:with] ||= {}
    locals = { :treatments => treatments }.merge(options[:with])
    render :partial => 'diseases/treatments/list', :locals => locals
  end

  def associate_disease_treatments_options(disease)
    { :list_id => 'search_results',
      :action => associate_disease_treatments_path(disease),
      :action_text => t(:add)
    }
  end

  def disassociate_disease_treatments_options(disease)
    { :list_id => 'associated_treatments',
      :action => disassociate_disease_treatments_path(disease),
      :action_text => t(:remove)
    }
  end
end
