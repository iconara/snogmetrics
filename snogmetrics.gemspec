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

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'snogmetrics'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'BlueCloth'
  s.add_development_dependency 'rails', '~> 4.2'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map { |f| f =~ /^bin\/(.*)/ ? Regexp.last_match(1) : nil }.compact
  s.require_path = 'lib'
end
