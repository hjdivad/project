#!/usr/bin/env ruby

__DIR__ = File.dirname( __FILE__ )


require 'fileutils'

require 'rubygems'
require 'spec'
require 'spec/rake/spectask'


Version = '0.1'
InstallRoot = ENV['INSTALL_DIR'] || "#{ENV['HOME']}/local"
InstallBinDir = "#{InstallRoot}/bin"
InstallShareDir = "#{InstallRoot}/share/project"


desc "Installs +project+ to INSTALL_DIR, which defaults to $HOME/local/bin"
task :install do
	FileUtils.mkdir_p InstallRoot
	FileUtils.mkdir_p InstallBinDir
	FileUtils.mkdir_p InstallShareDir

	FileUtils.cp_r Dir["#{__DIR__}/bin/*"], InstallBinDir
	FileUtils.cp_r Dir["#{__DIR__}/share/*"], InstallShareDir
end

