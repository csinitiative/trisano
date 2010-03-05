ActionController::Routing::Routes.draw do |map|

  map.resource :default_locale, :except => [:new, :create, :destroy]

end
