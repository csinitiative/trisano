ActionController::Routing::Routes.draw do |map|
  
  map.home '', :controller => 'dashboard'
  
  map.with_options :controller => 'search' do |search|
    search.search_cmrs   'search/cmrs',         :action => 'cmrs'
    search.cmrs_format   'search/cmrs.:format', :action => 'cmrs'
    search.search_people 'search/people',       :action => 'people'
    search.search        'search'
  end
  
  map.admin 'admin', :controller => 'admin'
  map.builder 'forms/builder/:id', :controller => 'forms', :action => 'builder'
  map.order_section_children 'forms/order_section_children/:id', :controller => 'forms', :action => 'order_section_children'
  map.toggle_value 'value_set_elements/toggle_value/:value_element_id', :controller => 'value_set_elements', :action => 'toggle_value'

  map.resources :entities do |entity|
    entity.resources :locations
  end
  
  map.resources :forms

  map.resources :external_codes

  map.resources :question_elements
  
  map.resources :group_elements

  map.resources :section_elements

  map.resources :value_set_elements
  
  map.resources :core_view_elements
  
  map.resources :core_field_elements
  
  map.resources :view_elements
  
  map.resources :form_elements, :member => { :to_library => :post }, :member => { :from_library => :post }
  
  map.resources :follow_up_elements

  map.resources :users
  
  map.resources :cmrs, 
                :controller => :morbidity_events,
                :member => { :state => :post, :jurisdiction => :post },
                :has_many => [:treatments, :clinicians]

  map.resources :contact_events, 
                :has_many => [:treatments, :clinicians]

  map.resources :codes, :controller => :external_codes

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
