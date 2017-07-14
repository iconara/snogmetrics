# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'snogmetrics'

Gem::Specification.new do |s|
  s.name        = 'snogmetrics'
  s.version     = Snogmetrics::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Theo Hultberg']
  s.email       = ['theo@iconara.net']
  s.homepage    = 'http://github.org/iconara/snogmetrics'
  s.summary     = 'SNOGmetrics is a KISSmetrics helper for Rails'
  s.description = 'SNOGmetrics gives you the best of both worlds: access to KISSmetrics\' JavaScript API through Ruby'
  s.license     = 'MIT'

  s.required_rubygems_version = '>= 1.3.6'

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|example)/})
  end
  s.bindir        = 'bin'
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 1.14'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'yard', '~> 0.9'
  s.add_development_dependency 'rails', '~> 4.2'
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'rubocop', '~> 0.49'
end
