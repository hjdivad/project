#!/usr/bin/env ruby

require 'lib/util'


module Project; end
module Project::Gitosis

	class Conf < Struct.new( :groups )
		Group = ::Struct.new( :name, :members, :writable )

		def self.load( path )
			group = nil
			groups = []
			File.new( path ).each_line do |line|
				case line
				when /\[group (\w*)\]/
					groups << group = Group.new( $1, [], [] )
				when /\s*writable\s*=\s*(.*)/
					group.writable += $1.split( " " )
				when /\s*members\s*=\s*(.*)/
					group.members += $1.split( " " )
				end
			end

			Conf.new( groups )
		end


		def to_s( patstr = nil )
			patstr ||= '.*'
			pattern = Regexp.new( patstr )

			groups.select do |g|
				g.name =~ pattern or
				g.writable.any?{|w| w =~ pattern}
			end.map do |g|
				"
					[group #{g.name}]

					  members = \n    #{g.members.join( "\n    " )}

					  writable = \n    #{g.writable.join( "\n    " )}
				".strip.gsub( /^\t{5}/, '' )
			end.join( "\n\n" )
		end
	end


	class << self
		def list( args, cmd_opts, global_opts )

			pattern = *args
			conf_path = global_opts[ :gitosis_conf ]

			conf = Conf.load( conf_path )

			puts conf.to_s( pattern )
		end
	end
end


module Gitosis


	################################################################ # {{{
	# Finding what to edit in gitosis.conf

	Project = "projects"
	Prefix = "#{ENV['USER']}/projects"
	
	# }}}

	################################################################

	Url = "git@cerberus.hjdivad.com:#{Prefix}"
end


# Add entry +Gitosis::Prefix+/+name+ to gitosis.conf
def update_gitosis_conf!( name )
	config = File.readlines( Gitosis::Path )
	File.open( Gitosis::Path, 'w' ) do |f|
		# simple state machine: are we in [group project]?
		in_project_group = false

		config.each do |line|
			if line =~ /\[group #{Gitosis::Project}\]/
				in_project_group = true
			elsif line =~ /\[group .*\]/
				in_project_group = false
			end

			if in_project_group
				if line =~ /^(\s*writable\s*=.*)\n/
					line = "#{$1} #{Gitosis::Prefix}/#{name}"
				end
			end

			f.print line
		end
	end
end

def commit_push_gitosis!( name )
	system [
		"cd #{Gitosis::Dir}",
		"git commit --all -m 'Added project #{name}.'",
		"git push",
	].join( " && " )
end

def add_origin_to_repo!( name )
	if File.directory? name
		system [
			"cd #{name}",
			"git remote add origin #{Gitosis::Url}/#{name}",
			"git config branch.master.remote origin",
			"git config branch.master.merge refs/heads/master",
			"git push origin master",
		].join( " && " )
	end
end

def command!( args )


	opts = Trollop::options do
		version			Version
		banner "
			Usage: setup-gitosis <dir> [<template>] [<hook-args>]

			Creates directory <dir>, copied from
			$HOME/local/share/project/templates/<template>, if given, and
			initializes as a git repository with a single, empty, root commit. 

			Runs $HOME/local/share/project/after/<template>/*, if any, passing in
			<name> and <hook-args> as arguments.
		".gsub( /^[ \t]+/, '' )

		opt :name,		"Name of the project.  Defaults to <dir>.",
			:type => :string
		opt :namespace,	"Namespace to use in gitosis.  Defaults to 'project'.",
			:type => :string
	end

	Trollop::die "<dir> is required." if ARGV.empty?


	name = args.first

	update_gitosis_conf!( name )
	commit_push_gitosis!( name )
	add_origin_to_repo!( name )
end


command!( ARGV ) if $0 == __FILE__

