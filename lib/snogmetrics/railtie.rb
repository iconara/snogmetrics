require 'snogmetrics'
require 'rails'

module Snogmetrics
  class Railtie < Rails::Railtie
    config.after_initialize do
      ::ActionController::Base.send(:include, Snogmetrics)
      ::ActionView::Base.send(:include, Snogmetrics)
    end
  end
end
