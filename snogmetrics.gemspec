# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{snogmetrics}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Theo"]
  s.date = %q{2010-03-30}
  s.description = %q{SNOGmetrics gives you the best of both worlds: access to KISSmetrics' JavaScript API through Ruby}
  s.email = %q{theo@iconara.net}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.mdown"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "Gemfile",
     "LICENSE",
     "README.mdown",
     "Rakefile",
     "example/snoggy/.gitignore",
     "example/snoggy/README.mdown",
     "example/snoggy/Rakefile",
     "example/snoggy/app/controllers/application_controller.rb",
     "example/snoggy/app/controllers/snogs_controller.rb",
     "example/snoggy/app/views/layouts/application.html.erb",
     "example/snoggy/app/views/snogs/new.html.erb",
     "example/snoggy/app/views/snogs/thank_you.html.erb",
     "example/snoggy/config/boot.rb",
     "example/snoggy/config/environment.rb",
     "example/snoggy/config/environments/development.rb",
     "example/snoggy/config/environments/production.rb",
     "example/snoggy/config/environments/test.rb",
     "example/snoggy/config/initializers/snogmetrics.rb",
     "example/snoggy/config/routes.rb",
     "example/snoggy/script/about",
     "example/snoggy/script/console",
     "example/snoggy/script/dbconsole",
     "example/snoggy/script/destroy",
     "example/snoggy/script/generate",
     "example/snoggy/script/performance/benchmarker",
     "example/snoggy/script/performance/profiler",
     "example/snoggy/script/plugin",
     "example/snoggy/script/runner",
     "example/snoggy/script/server",
     "example/snoggy/vendor/plugins/snogmetrics/init.rb",
     "lib/snogmetrics.rb",
     "rails/init.rb",
     "spec/snogmetrics_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/iconara/snogmetrics}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{SNOGmetrics is a KISSmetrics helper for Rails}
  s.test_files = [
    "spec/snogmetrics_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

