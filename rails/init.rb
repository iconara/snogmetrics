require 'snogmetrics'

ActionController::Base.send(:include, Snogmetrics)
ActionView::Base.send(:include, Snogmetrics)
