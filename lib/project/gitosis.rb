#!/usr/bin/env ruby

require 'project/util'


module Project; end
module Project::Gitosis

	class Conf < Struct.new( :groups, :path )
		Group = ::Struct.new( :name, :members, :writable )

		def self.line_type( line )
			case line
			when /\[group (\S*)\]/
				yield :group, $1
			when /\s*writable\s*=\s*(.*)/
				yield :writable, $1
			when /\s*members\s*=\s*(.*)/
				yield :members, $1
			end
		end

		def self.load( path )
			group = nil
			groups = []
			File.new( path ).each_line do |line|
				line_type( line ) do |type, v|
					case type
					when :group
						groups << group = Group.new( v, [], [] )
					when :writable
						group.writable += v.split( " " )
					when :members
						group.members += v.split( " " )
					end
				end
			end

			Conf.new( groups, path )
		end

		def save!
			# Groups to write
			groups = self.groups.ddup
			# current group
			group = nil

			# Read entire file into memory.
			file = File.readlines( self.path ).map do |line|
				Conf.line_type( line ) do |type, v|
					case type
					when :group
						group = groups.find{|g| g.name == v}
						groups.delete group unless group.nil?
					when :writable
						unless group.nil?
							line = "writable = "
							line << group.writable.sort.join( " " )
						end
					when :members
						unless group.nil?
							line = "members = "
							line << group.members.sort.join( " " )
						end
					end
				end

				line.chomp!( "\n" )
				line
			end
			
			# FIXME 3: Doesn't write new groups
			File.open( self.path, 'w' ){|f| f.puts( file.join( "\n" ))}
		end

		def add_writable!( path, group_name )
			group = group!( group_name )
			unless group.writable.find{|w| w == path }
				group.writable << path
			end
		end

		# Find group by name.  Create if none found.
		def group!( name )
			group = groups.find{|g| g.name == name}
			if group.nil?
				groups << group = Group.new( name, [], [] )
			end

			group
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
		def list( args, opts )

			pattern = *args
			conf_path = opts[ :gitosis_conf ]

			conf = Conf.load( conf_path )

			puts conf.to_s( pattern )
		end

		def add( name, directory, opts )
			conf_path = opts[ :gitosis_conf ]
			conf = Conf.load( conf_path )

			group_name	= opts[ :group ] || 'projects'
			path		= opts[ :path ] || 'projects'
			full_path	= "#{path}/#{name}"
			conf.add_writable!( full_path, group_name )
			conf.save!


			if( opts[ :push ])
				# Commit changes to gitosis
				gitosis_dir = File.dirname( conf_path )
				system [
					"cd #{gitosis_dir}",
					"git commit --all -m 'Added project #{name}.'",
					"git push",
				].join( " && " )

				# Add the newly created remote as the origin
				gitosis_url = (`
					cd #{gitosis_dir} && 
					git config remote.origin.url 
				` =~ /(.*):/; $1)
				system "
					cd #{directory}
					&& git remote | grep -q origin
					|| git remote add origin #{gitosis_url}:#{full_path}
					&& git config branch.master.remote origin
					&& git config branch.master.merge refs/heads/master
					&& git push origin master
				".gsub( "\n", " " )
			end
		end
	end
end

