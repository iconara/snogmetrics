# -*- encoding: utf-8 -*-
require File.expand_path('../lib/snogmetrics', __FILE__)

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

  s.add_development_dependency 'bundler', '~> 1.0.0'
  s.add_development_dependency 'rake', '~> 0.8.7'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'BlueCloth'
  s.add_development_dependency 'rails'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rcov'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
