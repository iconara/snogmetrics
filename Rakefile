require 'spec/rake/spectask'


begin
  require 'jeweler'
  require File.expand_path('../lib/snogmetrics', __FILE__)
  Jeweler::Tasks.new do |gem|
    gem.name = 'snogmetrics'
    gem.summary = %Q{SNOGmetrics is a KISSmetrics helper for Rails}
    gem.description = %Q{SNOGmetrics gives you the best of both worlds: access to KISSmetrics' JavaScript API through Ruby}
    gem.email = 'theo@iconara.net'
    gem.homepage = 'http://github.com/iconara/snogmetrics'
    gem.authors = ['Theo']
    gem.version = Snogmetrics::VERSION
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort 'YARD is not available. In order to run yardoc, you must: sudo gem install yard'
  end
end
