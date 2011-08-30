require 'snogmetrics/railtie' if defined? Rails::Railtie

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
  VERSION = '0.1.8'

  # Returns an instance of KissmetricsApi, which is an interface to the
  # KISSmetrics API. It has the methods #record and #identify, which work just
  # like the corresponding methods in the JavaScript API.
  def km
    @km_api ||= KissmetricsApi.new(kissmetrics_api_key, session, output_strategy)
  end

  # Override this method to set the KISSmetrics API key
  def kissmetrics_api_key
    ''
  end

  # Override this method to set the output strategy.
  # Available return values:
  #
  # :console_log use console.log to display events pushed to KISSmetrics
  # :array       store events pushed to KISSmetrics on _kmq
  # :live        send events to KISSmetrics via the async JS API
  def output_strategy
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
      ! Rails.env.production?
    else
      false
    end
  end

  
private

  class KissmetricsApi
    # Do not instantiate KissmetricsApi yourself, instead mix in Snogmetrics
    # and use it's #km method to get an instance of KissmetricsApi.
    def initialize(api_key, session, output_strategy)
      @session         = session
      @api_key         = api_key
      @output_strategy = output_strategy
    end
    
    # The equivalent of the `KM.record` method of the JavaScript API. You can
    # pass either an event name, an event name and a hash of properties, or only
    # a hash of properties.
    def record(*args)
      raise 'Not enough arguments' if args.size == 0
      raise 'Too many arguments' if args.size > 2
      
      queue << ['record', *args]
    end
    
    # The equivalent of the `KM.identify` method of the JavaScript API.
    def identify(identity)
      unless @session[:km_identity] == identity
        queue.delete_if { |e| e.first == 'identify' }
        queue << ['identify', identity]
        @session[:km_identity] = identity
      end
    end
    
    # The equivalent of the `KM.trackClick` method of the JavaScript API. The first
    # argument should be a selector (a tag id or class name). Furthermore you can
    # pass either an event name, an event name and a hash of properties, or only
    # a hash of properties.
    def trackClick(selector, *args)
      raise 'Not enough arguments' if args.size == 0
      raise 'Too many arguments' if args.size > 2

      queue << ['trackClick', selector, *args]
    end

    # Register which variant the user saw in an A/B test.
    def set(experiment, variant)
      queue << ['set', { experiment => variant }]
    end
    
    # Equivalent to `js(:reset => true)`, i.e. returns the JavaScript code
    # needed to load the KISSmetrics API and send the current state, and reset
    # the state afterwards.
    def js!
      js(:reset => true)
    end
    
    # In most situations you want the #js! method instead of this one.
    #
    # Returns the JavaScript needed to send the current state to KISSmetrics.
    # This includes the a JavaScript tag that loads the API code (or a fake API
    # that sends events to the console or a global array if the `output_strategy`
    # parameter to #initialize is :console_log or :array), as well as statements
    # that push the current state onto the `_kmq` array.
    #
    # You can pass the option `:reset` to reset the state, this makes sure that
    # subsequent calls to #js will not send events that have already been sent.
    def js(options={})
      options = {:reset => false}.merge(options)

      buffer = queue.map { |item| %(_kmq.push(#{item.to_json});) }

      queue.clear if options[:reset]

      <<-JAVASCRIPT
      <script type="text/javascript">
      var _kmq = _kmq || [];
      #{api_js}
      #{buffer.join("\n")}
      </script>
      JAVASCRIPT
    end
  
  private
  
    def queue
      @session[:km_queue] ||= []
    end
    
    def api_js
      if @output_strategy == :console_log
        <<-JS
        if (window.console) {
          _kmq = (function(queue) {
            var printCall = function() {
              console.dir(arguments);
            }

            for (var i = 0; i < queue.length; i++) {
              printCall.apply(null, queue[i]);
            }

            return {push: printCall};
          })(_kmq);
        }
        JS
      elsif @output_strategy == :live
        %((function(){function _kms(u,d){if(navigator.appName.indexOf("Microsoft")==0 && d)document.write("<scr"+"ipt defer='defer' async='true' src='"+u+"'></scr"+"ipt>");else{var s=document.createElement('script');s.type='text/javascript';s.async=true;s.src=u;(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(s);}}_kms('https://i.kissmetrics.com/i.js');_kms('http'+('https:'==document.location.protocol ? 's://s3.amazonaws.com/' : '://')+'scripts.kissmetrics.com/#{@api_key}.1.js',1);})();)
      elsif @output_strategy == :array
        ""
      else
        raise "Unknown KISSmetrics output strategy: #{@output_strategy}"
      end
    end
  end
end
