RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.frameworks -= [:active_record, :active_resource, :action_mailer]
  config.action_controller.session = {:key => '_snoggy_session', :secret => 'd08d2ef897ba8d7477bc3088dde396ac'}
end