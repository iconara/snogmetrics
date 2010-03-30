$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'snogmetrics'
require 'active_support'
require 'action_view/erb/util'
require 'spec'
require 'spec/autorun'


alias :running :lambda

Spec::Runner.configure do |config|
  
end