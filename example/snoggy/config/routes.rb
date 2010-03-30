ActionController::Routing::Routes.draw do |map|
  map.resources :snogs, :only => %w(new create), :collection => {:thank_you => :get}
  map.root :controller => :snogs, :action => :new
end
