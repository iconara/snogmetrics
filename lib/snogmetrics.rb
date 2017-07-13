require 'snogmetrics/railtie' if defined? Rails::Railtie
require 'snogmetrics/kissmetrics_api'

# If SNOGmetrics is used as a Rails plugin, this module is automatically mixed
# into ActionController::Base, so that it's #km method is available in
# controllers and in views.
#
# If not used as a Rails plugin, make sure that the context where Snogmetrics
# is mixed in defines #session (which should return hash).
#
# You should override #kissmetrics_api_key in an initializer to set the
# KISSmetrics API key.
#
# You can also override #output_strategy to provide your own logic for
# when the real KISSmetrics API, console.log fake, and array fake should be used.
# The console_log output strategy outputs all events to the console (if the console is defined).
# The array output strategy simply logs all events in the _kmq variable.
# The live output strategy sends calls to the async KISSmetrics JS API.
#
# The default implementation outputs the real API only when
# `Rails.env.production?` is true, and otherwise uses console.log
module Snogmetrics
  VERSION = '0.2.1'.freeze

  class << self
    attr_accessor :kissmetrics_api_key, :output_strategy
  end

  # Returns an instance of KissmetricsApi, which is an interface to the
  # KISSmetrics API. It has the methods #record and #identify, which work just
  # like the corresponding methods in the JavaScript API.
  def km
    @km_api ||= KissmetricsApi.new(Snogmetrics.kissmetrics_api_key, session, output_strategy)
  end

  # Override this method to set the output strategy.
  # Available return values:
  #
  # :console_log use console.log to display events pushed to KISSmetrics
  # :array       store events pushed to KISSmetrics on _kmq
  # :live        send events to KISSmetrics via the async JS API
  def output_strategy
    Snogmetrics.output_strategy ||
      if use_fake_kissmetrics_api?
        :console_log
      else
        :live
      end
  end

  # Deprecated: Prefer overriding #output_strategy to control the output strategy.
  #
  # Override this method to customize when the real API and when the stub API
  # will be outputted.
  def use_fake_kissmetrics_api?
    if defined? Rails
      !Rails.env.production?
    else
      false
    end
  end
end
