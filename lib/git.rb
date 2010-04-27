#!/usr/bin/env ruby


def add_as_submodule!( path, git_dir )
	origin = %x{
		cd #{path} && git config remote.origin.url
	}.chomp

	return if origin.empty?


	system [
		"cd #{git_dir}",
		"git submodule add #{origin} #{path}"
	].join( " && " )
end

def command!( args )

	name = args.first

	dir = File.expand_path( Dir.pwd )
	while not dir =~ %r{^\/?$} and not File.directory?( "#{dir}/.git" )
		dir = dir.split( "/" )[0..-2].join( "/" )
	end

	return unless File.directory? dir

	add_as_submodule!( name, dir )
end


command!( ARGV ) if $0 == __FILE__

