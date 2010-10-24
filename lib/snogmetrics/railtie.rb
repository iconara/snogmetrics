require 'snogmetrics'
require 'rails'


module Snogmetrics
  class Railtie < Rails::Railtie
    initializer 'my_railtie.configure_rails_initialization' do
      ActionController::Base.send(:include, Snogmetrics)
      ActionView::Base.send(:include, Snogmetrics)
    end
  end
end
