#!/usr/bin/env ruby

__DIR__ = File.dirname( __FILE__ )


require 'fileutils'

require 'rubygems'
require 'hoe'
require 'spec'
require 'spec/rake/spectask'


Hoe.spec 'project' do
	developer( 'David JH', 'davidjh@hjdivad.com' )

	self.version = "0.0.2"
	# self.rubyforge_name = 'project'
end


desc "Automatically update Manifest.txt"
task :update_manifest do
	File.open( './Manifest.txt', 'w' ) do |f|
		f.puts(
			(Dir['**/**'] + Dir['*/**/.[a-z]*']).uniq.reject do |p|
				p =~ /^(pkg|tmp)/
			end.reject do |p|
				File.directory? p
			end.join( "\n" )
		)
	end
end


# Spec ################################################################ {{{

$append_spec_opts = ''

namespace :spec do

	Spec::Rake::SpecTask.new( :run_spec ) do |t|
		t.spec_opts = proc do
			[ "--color --format specdoc #{$append_spec_opts}" ]
		end
	end

	task :spec, [ :spec_to_run ] do |t, args|
		$append_spec_opts = "-e #{args.spec_to_run}" unless args.spec_to_run.nil?
		Rake.application.invoke_task( "spec:run_spec" )
	end

end

desc "Run specs.  If +spec_to_run+ is specified, run only that spec."
task :spec, [ :spec_to_run ] => "spec:spec"

# }}}






# vim: syntax=ruby

