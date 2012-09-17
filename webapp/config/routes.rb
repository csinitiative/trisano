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

ActionController::Routing::Routes.draw do |map|

  map.process_condition 'question_elements/process_condition', :controller => 'question_elements', :action => 'process_condition'
  map.process_core_condition 'follow_up_elements/process_core_condition', :controller => 'follow_up_elements', :action => 'process_core_condition'

  map.resources :diseases do |diseases|
    diseases.resources :core_fields, :collection => {
      :apply_to => :post
    }
    diseases.resources :treatments, :only => [:index], :collection => {
      :associate => :post,
      :disassociate => :post,
      :apply_to => :post
    }
  end

  map.resources :managed_contents, :controller => 'managed_contents',  :only => [:edit, :update]

  map.resources :access_records
  map.resources :event_queues
  map.resources :export_columns, :has_many => :export_conversion_values

  map.resources :common_test_types, :member => { :loinc_codes => :get, :update_loincs => :post }
  map.resources :loinc_codes
  map.resources :organisms

  # When we get to Rails 2.1 restrict here for GET only
  map.resources :cdc_events, :collection => {
    :current_week => :get,
    :current_ytd => :get,
    :by_range => :get
  }

  map.resources :ibis_events, :collection => { :by_range => :get }

  map.home '', :controller => 'dashboard'
  map.calendar 'calendar/:year/:month', :controller => 'dashboard', :action => 'calendar', :month => Time.now.month, :year => Time.now.year

  map.with_options :controller => 'search' do |search|
    search.search_events   'search/events',           :action => 'events'
    search.events_format   'search/events.:format',   :action => 'events'
    search.search        'search',                :action => 'events'
  end

  map.settings 'users/settings', :controller => 'users', :action => 'settings'
  map.shortcuts 'users/shortcuts', :controller => 'users', :action => 'shortcuts', :conditions => { :method => :get } #always your own user
  map.shortcuts 'users/shortcuts', :controller => 'users', :action => 'shortcuts_update', :conditions => { :method => :put }
  map.shortcuts_edit 'users/shortcuts/edit', :controller => 'users', :action => 'shortcuts_edit'

  map.email_addresses 'users/email_addresses', :controller => 'users', :action => 'create_email_address', :conditions => { :method => :post }
  map.email_addresses 'users/email_addresses', :controller => 'users', :action => 'email_addresses'
  map.email_address 'users/email_addresses/:email_address_id', :controller => 'users', :action => 'destroy_email_address', :conditions => { :method => :delete }
  map.email_address_edit 'users/email_addresses/:email_address_id/edit', :controller => 'users', :action => 'edit_email_address', :conditions => { :method => :get }
  map.email_address_update 'users/email_addresses/:email_address_id', :controller => 'users', :action => 'update_email_address', :conditions => { :method => :put }

  map.admin 'admin', :controller => 'admin'
  map.analysis 'analysis', :controller => 'analysis'
  map.open_library 'forms/import', :controller => 'forms', :action => 'import'
  map.open_library 'forms/library_admin/:type', :controller => 'forms', :action => 'library_admin'
  map.order_section_children 'forms/order_section_children/:id', :controller => 'forms', :action => 'order_section_children'
  map.toggle_value 'value_set_elements/toggle_value/:value_element_id', :controller => 'value_set_elements', :action => 'toggle_value'

  map.resources :logos, :only => [:new, :create, :show, :delete]

  # Debt: Move to forms members
  map.builder 'forms/builder/:id', :controller => 'forms', :action => 'builder'
  map.form_rollback 'forms/rollback/:id', :controller => 'forms', :action => 'rollback'

  map.resources :forms,
    :member => {
      :copy => :post,
      :export => :post,
      :push => :post,
      :deactivate => :post} do |form|
    form.resource :questions
  end

  map.with_options :controller => 'external_codes' do |codes|
    codes.codes            'codes',                                   :action => 'index'
    codes.create_code      'codes/:code_name',                        :conditions => { :method => :post },  :action => 'create_code'
    codes.index_code       'codes/:code_name',                        :action => 'index_code'
    codes.formatted_index_code 'codes/:code_name.:format',            :action => 'index_code'
    codes.new_code         'codes/:code_name/new',                    :action => 'new_code'
    codes.update_code      'codes/:code_name/:the_code',              :conditions => { :method => :post },  :action => 'update_code'
    codes.show_code        'codes/:code_name/:the_code',              :action => 'show_code'
    codes.edit_code        'codes/:code_name/:the_code/edit',         :action => 'edit_code'
    codes.soft_delete_code 'codes/:code_name/:the_code/soft_delete',  :action => 'soft_delete_code'
    codes.soft_undelete_code 'codes/:code_name/:the_code/soft_undelete',  :action => 'soft_undelete_code'
  end

  map.resources :question_elements

  map.resources :group_elements

  map.resources :section_elements

  map.resources :value_set_elements

  map.resources :value_elements

  map.resources :core_view_elements

  map.resources :core_field_elements

  map.resources :view_elements

  map.resources :form_elements, {
    :member => {
      :to_library => :post,
      :from_library => :post,
      :update_export_column => :post
    }
  }

  map.resources :follow_up_elements

  map.resources :users

  map.resources :roles

  map.resources :people,
    :collection => {
      :search => :post,
    }

  map.resources :aes,
    :controller => :assessment_events,
    :collection => {
      :event_search => [:get, :post], #don't want to do this, but need to POST to keep patient info out of browser history
      :new => [:get, :post],  #don't want to do this, but need to POST to keep patient info out of browser history
      :export => :post  # Don't want to do this, but IE can't handle URLs > 2k
    },
    :member => {
      :state => :post,
      :edit_jurisdiction => :get,
      :jurisdiction => :post,
      :soft_delete => :post,
      :export_single => :post,
      :event_type => :post
    },
    :new => {
      :lab_form => :get,
      :lab_result_form => :get
    }


  map.resources :cmrs,
    :controller => :morbidity_events,
    :collection => {
      :event_search => [:get, :post], #don't want to do this, but need to POST to keep patient info out of browser history
      :new => [:get, :post], #don't want to do this, but need to POST to keep patient info out of browser history
      :export => :post  # Don't want to do this, but IE can't handle URLs > 2k
    },
    :member => {
      :state => :post,
      :edit_jurisdiction => :get,
      :jurisdiction => :post,
      :soft_delete => :post,
      :export_single => :post
    },
    :new => {
      :lab_form => :get,
      :lab_result_form => :get
    }

  map.resources :contact_events,
    :member => {
      :soft_delete => :post,
      :event_type => :post,
      :copy_address => :get,
      :edit_jurisdiction => :get,
      :jurisdiction => :post,
      :state => :post
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
    },
    :new => {
      :lab_form => :get,
      :lab_result_form => :get
    }

  map.resources :library_elements,
    :only => [:index],
    :collection => {
    :import => :post,
    :export => :post
  }

  map.resources :events, :only => [:index]

  # These are the forms in use with and available to an event
  map.resources :forms, :path_prefix => '/events/:event_id', :name_prefix => 'event_', :controller => 'event_forms', :only => [:index, :create]

  # These are the tasks in use with and available to an event
  map.resources :tasks, :path_prefix => '/events/:event_id', :name_prefix => 'event_', :controller => 'event_tasks', :only => [:new, :edit, :create, :update, :index]

  # These are the tasks for a particular user.
  map.resources :tasks, :path_prefix => '/users/:user_id',   :name_prefix => 'user_',  :controller => 'user_tasks',  :only => [:index, :update]

  # These are the notes in use with and available to an event
  map.resources :notes, :path_prefix => '/events/:event_id', :name_prefix => 'event_', :controller => 'event_notes', :only => [:index]

  # An event's attachments
  map.resources :attachments, :path_prefix => '/events/:event_id', :name_prefix => 'event_', :controller => 'event_attachments', :except => [:edit]

  map.resources :access_records,
                :path_prefix => '/events/:event_id',
                :name_prefix => 'event_',
                :controller => 'event_access_records',
                :only => [:new, :create]

  map.resources :core_fields

  map.resources :csv_fields

  map.resources :staged_messages,
    :member => {
      :event_search => :post,
      :event => :post,
      :discard => :post
  },
    :collection => {
      :search => :get
  }

  map.resources :message_batches, :only => [:create, :show]

  map.resources :places

  map.resources :jurisdictions

  map.resources :avr_groups

  map.resources :treatments

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
