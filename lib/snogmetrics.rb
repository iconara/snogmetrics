module Snogmetrics
  VERSION = '0.1.0'
  
  def km
    @km_api ||= KissmetricsApi.new(kissmetrics_api_key, session)
  end

  # Override this method to set the KISSmetrics API key
  def kissmetrics_api_key
    ''
  end
  
private

  class KissmetricsApi
    include ERB::Util
    
    def initialize(api_key, session)
      @session = session
      @api_key = api_key
    end
    
    def record(*args)
      raise 'Not enough arguments' if args.size == 0
      raise 'Too many arguments' if args.size > 2

      @session[:km_events] ||= []

      if args.size == 1 && args.first.is_a?(Hash)
        @session[:km_events] << {:properties => args.first}
      elsif args.size == 1
        @session[:km_events] << {:name => args.first}
      else
        @session[:km_events] << {:name => args.first, :properties => args.last}
      end
    end
    
    def identify(identity)
      unless user_identified?(identity)
        @session[:km_identity] = identity
        @session[:km_user_identified] = nil
      end
    end
    
    def js(options={})
      options = {:reset => false}.merge(options)

      buffer = []

      unless user_identified? || @session[:km_identity].blank?
        identity = html_escape(@session[:km_identity])

        buffer << push_call('identify', identity)

        user_identified! if options[:reset]
      end

      unless events.empty?
        safe_events.each do |event|
          if event[:name].blank?
            buffer << push_call('record', event[:properties])
          elsif event[:properties].blank?
            buffer << push_call('record', event[:name])
          else
            buffer << push_call('record', event[:name], event[:properties])
          end
        end

        reset_events! if options[:reset]
      end

      if buffer.empty?
        ''
      else
        <<-JAVASCRIPT
        <script type="text/javascript">
        var _kmq = _kmq || [];
        #{api_js}
        #{buffer.join("\n")}
        </script>
        JAVASCRIPT
      end
    end
    
    def js!
      js(:reset => true)
    end
  
  private
    
    def user_identified?(who=nil)
      if who
        @session[:km_user_identified] == who
      else
        !!@session[:km_user_identified]
      end
    end
    
    def push_call(*args)
      %(_kmq.push(#{args.to_json});)
    end
    
    def api_js
      if Rails.env.production?
        %((function(){function _kms(u,d){if(navigator.appName.indexOf("Microsoft")==0 && d)document.write("<scr"+"ipt defer='defer' async='true' src='"+u+"'></scr"+"ipt>");else{var s=document.createElement('script');s.type='text/javascript';s.async=true;s.src=u;(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(s);}}_kms('https://i.kissmetrics.com/i.js');_kms('http'+('https:'==document.location.protocol ? 's://s3.amazonaws.com/' : '://')+'scripts.kissmetrics.com/#{@api_key}.1.js',1);})();)
      else
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
      end
    end
    
    def events
      @session[:km_events] || []
    end

    def reset_events!
      @session[:km_events] = []
    end
    
    def user_identified!
      @session[:km_user_identified] = @session[:km_identity]
      @session[:km_identity] = nil
    end
    
    def safe_properties(hash)
      return {} if hash.nil? || hash.empty?
      hash.keys.inject({}) do |h, k|
        h[html_escape(k)] = html_escape(hash[k])
        h
      end
    end
    
    def safe_events
      events.map do |event|
        safe_event = {}
        safe_event[:name] = html_escape(event[:name].strip) unless event[:name].blank?
        safe_event[:properties] = safe_properties(event[:properties]) unless event[:properties].blank?
        safe_event
      end
    end
  end
end