ActionController::Routing::Routes.draw do |map|

  map.home '', :controller => 'dashboard'
  map.search 'search', :controller => 'search'
  map.admin 'admin', :controller => 'admin'
  map.builder 'forms/builder/:id', :controller => 'forms', :action => 'builder'
  map.order_section_children_show 'forms/order_section_children_show/:form_element_id', :controller => 'forms', :action => 'order_section_children_show'
  map.order_section_children 'forms/order_section_children/:id', :controller => 'forms', :action => 'order_section_children'

  map.resources :entities, :member => { :promote => :post } do |entity|
    entity.resources :locations
  end
  
  map.resources :forms

  map.resources :external_codes

  map.resources :question_elements
  
  map.resources :group_elements

  map.resources :section_elements

  map.resources :value_set_elements
  
  map.resources :core_view_elements
  
  map.resources :view_elements
  
  map.resources :form_elements, :member => { :to_library => :post }, :member => { :from_library => :post }
  
  map.resources :follow_up_elements

  map.resources :users

  map.resources :cmrs, :controller => :events do |cmr|
    cmr.resources :lab_results
    cmr.resources :treatments
    cmr.resources :contacts
    cmr.resources :clinicians
    cmr.resources :health_facilities
  end

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
