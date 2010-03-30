# This is where you configure SNOGmetrics. Just override the #kissmetrics_api_key
# method of the module to return the API key.
module Snogmetrics
  def kissmetrics_api_key
    'abc123'
  end
end

# If you need to load the API from a YAML file, you can do something like the
# following. It loads the key and puts it in a local variable, then it overrides
# the #kissmetrics_api_key method with a closure that has access to the local
# variable 'key'.
#key = YAML.load(ERB.new(File.read('path/to/file.yml')).result)[RAILS_ENV].symbolize_keys[:kissmetrics_api_key]
#Snogmetrics.send(:define_method, :kissmetrics_api_key) { key }