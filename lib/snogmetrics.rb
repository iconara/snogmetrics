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
# You can also override #use_fake_kissmetrics_api? to provide your own logic for
# when the real KISSmetrics API and when the fake should be used. The fake API
# simply outputs all events to the console (if the console is defined). The
# the default implementation outputs the real API only when 
# `Rails.env.production?` is true.
module Snogmetrics
  VERSION = '0.1.2'

  # Returns an instance of KissmetricsApi, which is an interface to the
  # KISSmetrics API. It has the methods #record and #identify, which work just
  # like the corresponding methods in the JavaScript API.
  def km
    @km_api ||= KissmetricsApi.new(kissmetrics_api_key, session, use_fake_kissmetrics_api?)
  end

  # Override this method to set the KISSmetrics API key
  def kissmetrics_api_key
    ''
  end
  
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
    def initialize(api_key, session, fake_it)
      @session = session
      @api_key = api_key
      @fake_it = fake_it
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
    # that sends events to the console if the `fake_it` parameter to #initialize
    # is true), as well as statements that push the current state onto the 
    # `_kmq` array.
    #
    # You can pass the option `:reset` to reset the state, this makes sure that
    # subsequent calls to #js will not send events that have already been sent.
    def js(options={})
      options = {:reset => false}.merge(options)
      
      if queue.empty?
        ''
      else
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
    end
  
  private
  
    def queue
      @session[:km_queue] ||= []
    end
    
    def api_js
      if @fake_it
        <<-JS
        var KM = {
          record: function() {
            _kmq.push(["record"].concat(Array.prototype.slice.apply(arguments)));
          },
          identify: function() {
            _kmq.push(["identify"].concat(Array.prototype.slice.apply(arguments)));
          }
        };

        if (window.console) {
          _kmq = (function(queue) {
            function printCall() {
              console.dir(arguments);
            }

            for (var i = 0; i < queue.length; i++) {
              printCall.apply(null, queue[i]);
            }

            return {push: printCall};
          })(_kmq);
        }
        JS
      else
        %((function(){function _kms(u,d){if(navigator.appName.indexOf("Microsoft")==0 && d)document.write("<scr"+"ipt defer='defer' async='true' src='"+u+"'></scr"+"ipt>");else{var s=document.createElement('script');s.type='text/javascript';s.async=true;s.src=u;(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(s);}}_kms('https://i.kissmetrics.com/i.js');_kms('http'+('https:'==document.location.protocol ? 's://s3.amazonaws.com/' : '://')+'scripts.kissmetrics.com/#{@api_key}.1.js',1);})();)
      end
    end
  end
end