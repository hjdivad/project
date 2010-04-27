#!/usr/bin/env ruby

require 'lib/util'


module Project
end





def check_requirements!
	# TODO 2: check for git, maybe Templates/Hooks Root
end

def check_template! template, template_full_path
	if !template.nil? and !File.directory? template_full_path
		puts "No such template: #{template}: looking in #{TemplatesRoot}"
		exit 2
	end
end


class Hash
	def to_cmdline!
		map{|k,v| "#{k}=#{v}" unless v.nil?}.compact.join( " " )
	end
end


def command!( args )
	argv = ARGV.dup.join( " " )

	opts = Trollop::options do
		version			Version
		banner "
			Usage: project <dir> [<template>] [<hook-args>]

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
	check_requirements!


	directory, template = *args
	name = opts[ :name ] || directory

	template_full_path = "#{TemplatesRoot}/#{template}"

	check_template! template, template_full_path


	if File.exists? directory
		puts "#{directory} already exists.  Not copying from template."
	else
		msg = "Creating #{directory}"
		msg << " from template #{template}" unless template.nil?
		puts "#{msg}."

		# create the directory, copying everything from the template, if it was
		# given
		FileUtils.mkdir_p( directory )
		FileUtils.cp_r(
			Dir["#{template_full_path}/#{AllFilesPattern}"],
			directory
		) unless template.nil?
	end


	if File.exists? "#{directory}/.git"
		puts "#{directory} is already a git repository."
	else
		puts "Initializing git repository."
		# initialize  git repository
		commands = [
			"cd #{directory}",
			"git init",
			"git commit --allow-empty -m 'Root.'",
		]
		commands << "git add . && git commit -m 'Copied template.' " unless template.nil?
		system commands.join( " && " )
	end


	puts "Running hooks."
	# run hooks
	Dir["#{HooksRoot}/#{template}/#{AllFilesPattern}"].each do |hook|
		puts "Running #{hook}"
		system hook, argv
	end
end


command!( ARGV ) if $0 == __FILE__
