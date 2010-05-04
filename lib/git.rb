#!/usr/bin/env ruby

require 'util'

module Project; end
module Project::Git
	def self.add_as_submodule( directory, opts )

		# Walk backwards to find the nearest ancestor of directory that has a
		# child named .git
		submodule = File.expand_path( directory )
		dir = File.dirname( submodule )
		while not dir =~ %r{^\/?$} and not File.directory?( "#{dir}/.git" )
			dir = dir.split( "/" )[0..-2].join( "/" )
		end
		return unless File.directory? dir

		origin = %x{
			cd #{submodule} && git config remote.origin.url
		}.chomp
		return if origin.empty?


		# Submodule relative to dir
		submodule[ 0..dir.size ] = './'
		system [
			"cd #{dir}",
			"git submodule add #{origin} #{submodule}"
		].join( " && " )
	end
end

