require 'yaml'

require 'rubygems'
require 'project/tasks'
require 'rake'

Dir[ 'lib/tasks/**/*' ].each{ |l| require l }


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "project"
    gem.summary = %Q{create projects}
    gem.description = %Q{create projects, either on gitosis or github.}
    gem.email = "project@hjdivad.com"
    gem.homepage = "http://example.com"
    gem.authors = ["David J. Hamilton"]

    if File.exists? 'Gemfile'
      require 'bundler'
      bundler = Bundler.load
      bundler.dependencies_for( :runtime ).each do |dep|
        gem.add_dependency              dep.name, dep.requirement.to_s
      end
      bundler.dependencies_for( :development ).each do |dep|
        gem.add_development_dependency  dep.name, dep.requirement.to_s
      end
    end
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


desc "Run all specs."
task :spec do
  # Jeweler messes up specs by polluting ENV
  ENV.keys.grep( /git/i ).each{|k| ENV.delete k }
  sh "rspec spec"
end


begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  desc "Try (and fail) to run yardoc to get an error message."
  task :yard do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
