module Snogmetrics
  def km_identify(identity)
    unless km_user_identified?(identity)
      session[:km_identity] = identity
      session[:km_user_identified] = nil
    end
  end
  
  def km_record(*args)
    raise 'Not enough arguments' if args.size == 0
    raise 'Too many arguments' if args.size > 2
    
    session[:km_events] ||= []

    if args.size == 1 && args.first.is_a?(Hash)
      session[:km_events] << {:properties => args.first}
    elsif args.size == 1
      session[:km_events] << {:name => args.first}
    else
      session[:km_events] << {:name => args.first, :properties => args.last}
    end
  end
  
  def km_js(options={})
    options = {:reset => false}.merge(options)
    
    buffer = []

    unless km_user_identified? || session[:km_identity].blank?
      identity = html_escape(session[:km_identity])
      
      buffer << %[KM.identify("#{identity}");]

      km_user_identified! if options[:reset]
    end

    unless km_events.empty?
      km_safe_events.each do |event|
        properties_js = event[:properties].to_json
        
        if event[:name].blank?
          buffer << %[KM.record(#{properties_js});]
        elsif event[:properties].blank?
          buffer << %[KM.record("#{event[:name]}");]
        else
          buffer << %[KM.record("#{event[:name]}", #{properties_js});]
        end
      end

      km_reset_events! if options[:reset]
    end

    if buffer.empty?
      ''
    else
      <<-JAVASCRIPT
      #{km_api_js}
      <script type="text/javascript">
      var KM_KEY = "#{kissmetrics_api_key}";
      #{buffer.join("\n")}
      </script>
      JAVASCRIPT
    end
  end

  def km_js!
    km_js(:reset => true)
  end

  # Override this method to set the KISSmetrics API key
  def kissmetrics_api_key
    ''
  end
  
private
  
  def km_api_js
    if Rails.env.production?
      %(<script type="text/javascript" src="http://scripts.kissmetrics.com/t.js"></script>)
    else
      <<-JS
      <script type="text/javascript">
      var KM = (function() {
        var self = { };

        if (window.console) {
          self.record = function() {
            console.log("KM.record(...)")
            console.dir(arguments);
          }
          self.identify = function(who) {
            console.log("KM.identify(\\"" + who + "\\")")
          }
        } else {
          self.record = function() {}
          self.identify = function() {}
        }

        return self;
      })();
      </script>
      JS
    end
  end
  
  def km_events
    session[:km_events] || []
  end

  def km_reset_events!
    session[:km_events] = []
  end

  def km_user_identified!
    session[:km_user_identified] = session[:km_identity]
    session[:km_identity] = nil
  end

  def km_user_identified?(who=nil)
    if who
      session[:km_user_identified] == who
    else
      !!session[:km_user_identified]
    end
  end

  def km_safe_properties(hash)
    return {} if hash.nil? || hash.empty?
    hash.keys.inject({}) do |h, k|
      h[html_escape(k)] = html_escape(hash[k])
      h
    end
  end

  def km_safe_events
    km_events.map do |event|
      safe_event = {}
      safe_event[:name] = html_escape(event[:name].strip) unless event[:name].blank?
      safe_event[:properties] = km_safe_properties(event[:properties]) unless event[:properties].blank?
      safe_event
    end
  end
end