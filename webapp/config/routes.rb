# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

ActionController::Routing::Routes.draw do |map|

  map.process_condition 'question_elements/process_condition', :controller => 'question_elements', :action => 'process_condition'
  map.process_core_condition 'follow_up_elements/process_core_condition', :controller => 'follow_up_elements', :action => 'process_core_condition'

  map.resources :diseases

  map.resources :event_queues
  map.resources :export_columns, :has_many => :export_conversion_values

  # When we get to Rails 2.1 restrict here for GET only
  map.resources :cdc_events, :collection => { :current_week => :get, :current_ytd => :get, :by_range => :get }
    
  map.resources :ibis_events, :collection => { :by_range => :get }
  
  map.home '', :controller => 'dashboard'
  
  map.with_options :controller => 'search' do |search|
    search.search_cmrs   'search/cmrs',           :action => 'cmrs'
    search.cmrs_format   'search/cmrs.:format',   :action => 'cmrs'
    search.search        'search'
  end

  map.settings 'users/settings', :controller => 'users', :action => 'settings'
  map.shortcuts 'users/shortcuts', :controller => 'users', :action => 'shortcuts', :conditions => { :method => :get } #always your own user
  map.shortcuts 'users/shortcuts', :controller => 'users', :action => 'shortcuts_update', :conditions => { :method => :put }
  map.shortcuts_edit 'users/shortcuts/edit', :controller => 'users', :action => 'shortcuts_edit'
  map.admin 'admin', :controller => 'admin'
  map.avr 'avr', :controller => 'avr'
  map.open_library 'forms/import', :controller => 'forms', :action => 'import'
  map.open_library 'forms/library_admin/:type', :controller => 'forms', :action => 'library_admin'
  map.order_section_children 'forms/order_section_children/:id', :controller => 'forms', :action => 'order_section_children'
  map.toggle_value 'value_set_elements/toggle_value/:value_element_id', :controller => 'value_set_elements', :action => 'toggle_value'

  # Debt: Move to forms members
  map.builder 'forms/builder/:id', :controller => 'forms', :action => 'builder'
  map.form_rollback 'forms/rollback/:id', :controller => 'forms', :action => 'rollback'

  map.resources :forms, 
    :member => {
    :copy => :post,
    :export => :post,
    :push => :post,
    :deactivate => :post
  }

  map.resources :external_codes

  map.resources :question_elements
  
  map.resources :group_elements

  map.resources :section_elements

  map.resources :value_set_elements

  map.resources :value_elements
  
  map.resources :core_view_elements
  
  map.resources :core_field_elements
  
  map.resources :view_elements
  
  map.resources :form_elements, :member => { :to_library => :post }, :member => { :from_library => :post }
  
  map.resources :follow_up_elements

  map.resources :users

  map.resources :roles

  map.resources :people
  
  map.resources :cmrs, 
    :controller => :morbidity_events,
    :collection => {
    :event_search => :get,
    :export => :post,  # Don't want to do this, but IE can't handle URLs > 2k
  },
    :member => {
    :state => :post,
    :jurisdiction => :post,
    :soft_delete => :post,
    :export_single => :post,  # Don't want to do this, but IE can't handle URLs > 2k
  },
    :new => {
    :lab_form => :get,
    :lab_result_form => :get
  }

  map.resources :contact_events, 
    :member => {
    :soft_delete => :post,
    :event_type => :post
  },
    :new => {
    :lab_form => :get,
    :lab_result_form => :get
  }

  map.resources :place_events, :member => {
    :soft_delete => :post
  }

  map.resources :encounter_events,
    :member => {
    :soft_delete => :post
  }

  map.resources :library_elements,
    :only => [:index],
    :collection => {
    :import => :post,
    :export => :post
  }

  # These are the forms in use with and available to an event
  map.resources :forms, :path_prefix => '/events/:event_id', :name_prefix => 'event_', :controller => 'event_forms', :only => [:index, :create]

  # These are the tasks in use with and available to an event
  map.resources :tasks, :path_prefix => '/events/:event_id', :name_prefix => 'event_', :controller => 'event_tasks', :only => [:new, :edit, :create, :update, :index]

  # These are the tasks for a particular user.
  map.resources :tasks, :path_prefix => '/users/:user_id',   :name_prefix => 'user_',  :controller => 'user_tasks',  :only => [:index, :update]   

  # These are the notes in use with and available to an event
  map.resources :notes, :path_prefix => '/events/:event_id', :name_prefix => 'event_', :controller => 'event_notes', :only => [:index]

  # An event's attachments
  map.resources :attachments, :path_prefix => '/events/:event_id', :name_prefix => 'event_', :controller => 'event_attachments'

  map.resources :codes, :controller => :external_codes

  map.resources :core_fields
  
  map.resources :csv_fields

  map.resources :staged_messages,
    :member => {
      :event_search => :get,
      :event => :post,
      :discard => :post
    }

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
