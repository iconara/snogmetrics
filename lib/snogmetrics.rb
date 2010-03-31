module Snogmetrics
  VERSION = '0.1.1'
  
  def km
    @km_api ||= KissmetricsApi.new(kissmetrics_api_key, session)
  end

  # Override this method to set the KISSmetrics API key
  def kissmetrics_api_key
    ''
  end
  
private

  class KissmetricsApi
    def initialize(api_key, session)
      @session = session
      @api_key = api_key
    end
    
    def record(*args)
      raise 'Not enough arguments' if args.size == 0
      raise 'Too many arguments' if args.size > 2
      
      queue << ['record', *args]
    end
    
    def identify(identity)
      unless @session[:km_identity] == identity
        queue.delete_if { |e| e.first == 'identify' }
        queue << ['identify', identity]
        @session[:km_identity] = identity
      end
    end
    
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
    
    def js!
      js(:reset => true)
    end
  
  private
  
    def queue
      @session[:km_queue] ||= []
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
  end
end