#!/usr/bin/env ruby

require 'trollop'

require 'lib/git'
require 'lib/gitosis'
require 'lib/util'



module Project
	Version			= "0.1.1"
	TemplatesRoot	= "#{ENV['HOME']}/local/share/project/templates"
	HooksRoot		= "#{ENV['HOME']}/local/share/project/after"

	AllFilesPattern	= "{.,[a-zA-Z]}[a-zA-Z]*"


	SubCommands		= %w(
		create remove gitosis-list gitosis-add gitosis-remove submodulize help
	)


	def self.run!
		global_opts = Trollop::options do
			version	Version
			banner	"
				Manage projects saved in gitosis.

				project COMMAND [ARGS]

				Commands are:
					#{SubCommands.join( "
					")}


				Global options:
			".cleanup

			opt	:name,	"
				The name of the project.  If unspecified, will default to DIR,
				if relevant for the command
			".oneline

			opt :gitosis_conf, "
				The location of .gitosis-conf, which also implies the location
				of the gitosis directory.
			".oneline,
				:type		=> :string,
				:default	=> "#{ENV['HOME']}/devel/.gitosis-admin/gitosis.conf"

			stop_on	SubCommands
		end

		cmd = ARGV.shift
		cmd_opts = Trollop::options do
			case cmd
			when "create"
			when "remove"
			when "gitosis-list"
			when "gitosis-add"
			when "gitosis-remove"
			when "submodulize"
			when "help"
				help_cmd = ARGV.shift
				help_output = case help_cmd
					when "create"
					when "remove"
					when "gitosis-list"
						"
							project gitosis-list [PATTERN]

							List groups that match PATTERN, or have writables
							that match PATTERN.  PATTERN defaults to '.*'.
						"
					when "gitosis-add"
					when "gitosis-remove"
					when "submodulize"
					when "help"
						"
							project help COMMAND

							Provides help on projbect subcommand COMMAND.
						"
					else
						if help_cmd.nil?
							"
								project help COMMAND

								Provides help on projbect subcommand COMMAND.
							"
						else
							"
								Unknown command #{help_cmd}.  Try --help for a list
								of commands.
							"
						end
					end

				puts( help_output.cleanup )
				exit 0
			else
				Trollop::die "No command specified" if cmd.nil?
				Trollop::die "Unknown command #{cmd}"
			end
		end


		case cmd 
		when "create"
		when "remove"
		when "gitosis-list"
			Project::Gitosis::list( ARGV, cmd_opts, global_opts )
		when "gitosis-add"
		when "gitosis-remove"
		when "submodulize"
		when "help"
		else
			raise "Internal project error."
		end
	end
end
