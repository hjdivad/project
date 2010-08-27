require 'rubygems'
require 'rake'
require 'project/tasks'

Dir[ 'lib/tasks/**/*' ].each{ |l| require l }


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    # TODO 1: name
    gem.name = "TODO: name"
    gem.summary = %Q{TODO: description}
    gem.description = %Q{TODO: description}
    gem.email = "TODO: name @hjdivad.com"
    gem.homepage = "http://github.com/hjdivad/TODO: name"
    gem.authors = ["David J. Hamilton"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    gem.add_development_dependency "cucumber", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


desc "Write out build version.  You must supply BUILD."
task 'version:write:build' do
  unless ENV.has_key? 'BUILD'
    abort "Must supply BUILD=<build> to write out build version number." 
  end
  y = YAML::load_file( "VERSION.yml" )
  v = {
    :major => 0, :minor => 0, :patch => 0, :build => 0
  }
  v.merge!( y ) if y.is_a? Hash
  v[ :build ] = ENV['BUILD']
  File.open( "VERSION.yml", "w" ){|f| f.puts YAML::dump( v )}
end

task 'version:bump:build' do
  y = YAML::load_file( "VERSION.yml" )
  v = {
    :major => 0, :minor => 0, :patch => 0, :build => 0
  }
  v.merge!( y ) if y.is_a? Hash

  raise "Can't bump build: not a number" unless v[:build].is_a? Numeric
  v[ :build ] += 1

  v.each{|k,v| ENV[ k.to_s.upcase ] = v.to_s}
  Rake::Task["version:write"].invoke
end


desc "Run all specs."
task :spec do
  sh "rspec spec"
end


begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
