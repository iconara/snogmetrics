RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Usually you would add SNOGmetrics by adding the gem here, but in this
  # example app I have put the code as a plugin, because it's more convenient
  # when I code new features.
  #config.gem 'snogmetrics'
  
  config.frameworks -= [:active_record, :active_resource, :action_mailer]
  config.action_controller.session = {:key => '_snoggy_session', :secret => 'd08d2ef897ba8d7477bc3088dde396ac'}
end