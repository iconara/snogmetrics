module Snogmetrics
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
      raise 'Not enough arguments' if args.empty?
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
      raise 'Not enough arguments' if args.empty?
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
      js(reset: true)
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
    def js(options = {})
      options = { reset: false }.merge(options)

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
      case @output_strategy
      when :console_log
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
      when :live
        %(function _kms(e){setTimeout(function(){var s=document,t=s.getElementsByTagName("script")[0],c=s.createElement("script");c.type="text/javascript",c.async=!0,c.src=e,t.parentNode.insertBefore(c,t)},1)}_kms("//i.kissmetrics.com/i.js"),_kms("//scripts.kissmetrics.com/#{@api_key}.2.js");)
      when :array
        ''
      else
        raise "Unknown KISSmetrics output strategy: #{@output_strategy}"
      end
    end
  end
end
