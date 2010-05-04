#!/usr/bin/env ruby

require 'util'


module Project
	class << self

		def check_template! template, template_full_path
			if !template.nil? and !File.directory? template_full_path
				puts "No such template: #{template}: looking in #{TemplatesRoot}"
				exit 2
			end
		end

		def create_directory( directory, template, template_full_path )
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
		end

		def initialize_git( directory, used_template )
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
				commands << "git add . && git commit -m 'Copied template.' " if used_template
				system commands.join( " && " )
			end
		end


		def create( args, opts )
			directory, template = *args
			name = opts[ :name ] || File.basename( directory )
			templates_root = opts[ :templates_root ]
			template_full_path = "#{templates_root}/#{template}"

			check_template!		template, template_full_path

			create_directory 	directory, template, template_full_path
			initialize_git		directory, !template.nil?
		end
	end
end

