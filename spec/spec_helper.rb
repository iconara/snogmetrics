$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'snogmetrics'
require 'active_support/all'
require 'action_view'

alias running lambda

RSpec.configure do |config|
end
