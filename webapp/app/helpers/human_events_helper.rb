module HumanEventsHelper

  def basic_human_event_controls(event, view_mode)
    view_mode = :edit if ![:index, :edit, :show].include?(view_mode)

    can_update =  User.current_user.is_entitled_to_in?(:update_event, event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
    can_view =  User.current_user.is_entitled_to_in?(:view_event, event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
    can_create =  User.current_user.is_entitled_to_in?(:create_event, event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )

    controls = ""
    controls << link_to(t('show'), event_path(event), :class => "show_link") if ((view_mode == :index) && can_view)
    if can_update
      controls << " | " unless controls.blank?
      if (view_mode == :index)
        controls << link_to(t('edit'), edit_event_path(event), :class => "edit_link")
      elsif (view_mode == :edit)
        controls << link_to_function(t('show'), "send_url_with_tab_index('#{event_path(event)}')", :class => "show_link")
      else
        controls << link_to_function(t('edit'), "send_url_with_tab_index('#{edit_event_path(event)}')", :class => "edit_link")
      end
    end
    if can_view
      controls << " | " unless controls.blank?
      controls << link_to_function(t("print"), nil) do |page|
        page["printing_controls_#{event.id}"].visual_effect :appear, :duration => 0.0
      end
    end
    if event.deleted_at.nil? && can_update
      controls << " | " unless controls.blank?
      controls << link_to(t('delete'), soft_delete_event_path(event), :method => :post, :confirm => 'Are you sure?', :id => 'soft-delete')
    end
    if (view_mode != :index)
      if can_update
        controls << " | " unless controls.blank?
        if (view_mode == :edit)
          controls << link_to_remote(t('add_task'), :url => { :controller => 'event_tasks', :action => 'new', :event_id => event.id }, :method => :get )
        else
          controls << link_to(t('add_task'), new_event_task_path(event))
        end
        controls << " | " << link_to(t('add_attachment'), new_event_attachment_path(event))
        
        if event.is_a?(AssessmentEvent)
         controls << " | " << link_to(t(:promote_to_cmr), event_type_ae_path(event, :type => "morbidity_event"), :method => :post, :confirm => t(:are_you_sure), :id => 'event-type')
        end
      end
      if can_view
        controls << " | " unless controls.blank?
        controls << link_to_function(t('export_to_csv'), nil) do |page|
          page[:export_options].visual_effect :appear
        end
      end
      if can_create
        controls << " | " unless controls.blank?
        controls << link_to_function(t('create_new_event_from_this_one')) do |page|
          page[:copy_options].visual_effect :appear
        end
      end
    end
    controls
  end

  def new_human_event_search_results(results)
    results = NewHumanEventSearchResults.new(results, self)
    returning "" do |html|
      results.each do |result|
        html << new_human_event_search_result(result)
      end
    end
  end

  def new_human_event_search_result(result)
    tr_tag(:class => result.css_class, :id => result.css_id) do |tr|
      tr << td_tag(new_human_event_search_result_name(result))
      tr << td_tag(result.bdate)
      tr << td_tag(h(result.gender))
      tr << td_tag(result.event_type)
      tr << td_tag(h(result.jurisdiction))
      tr << td_tag(result.event_onset_date)
      tr << td_tag(h(result.disease_name))
      tr << td_tag(result.links)
      tr << td_tag(result.link_to_create_human_event)
    end
  end

  def new_human_event_search_result_name(result)
    result.name
  end

end
