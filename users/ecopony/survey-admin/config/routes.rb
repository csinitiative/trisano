ActionController::Routing::Routes.draw do |map|
  map.resources :form_statuses


  map.builder 'forms/builder/:id', :controller => 'forms', :action => 'builder'
  
  # A public form is starting to look like a resource of its own
  map.display_form 'forms/display/:id', :controller => 'forms', :action => 'display_form'
  map.process_form 'forms/process/:id', :controller => 'forms', :action => 'process_form'
  map.edit_form 'forms/edit/:id/:cmr_id', :controller => 'forms', :action => 'edit_form'
  
  map.resources :cmrs
  
  map.resources :answer_sets
  
  map.resources :answers

  map.resources :questions

  map.resources :question_types

  map.resources :groups

  map.resources :sections

  map.resources :forms

  map.resources :programs

  map.resources :jurisdictions

  map.resources :diseases

  # The priority is based upon order of creation: first created -> highest priority.

  map.home '', :controller => 'dashboard'
  
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
