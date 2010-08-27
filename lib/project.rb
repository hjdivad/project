#!/usr/bin/env ruby

require 'trollop'

require 'project/basic'
require 'project/git'
require 'project/github'
require 'project/gitosis'
require 'project/util'



module Project
  Version = lambda {
    h = YAML::load_file( "#{File.dirname( __FILE__ )}/../VERSION.yml" )
    if h.is_a? Hash
      [h[:major], h[:minor], h[:patch], h[:build]].compact.join( "." )
    end
  }.call

  AllFilesPattern = "{.,[a-zA-Z]}[a-zA-Z]*"

  # Defaults
  Share     = "#{File.dirname( File.dirname( __FILE__ ))}/share"
  TemplatesRoot = "#{Share}/templates"
  GitosisConf   = "#{ENV['HOME']}/devel/.gitosis-admin/gitosis.conf"


  SubCommands   = %w(
    create remove gitosis-list gitosis-add gitosis-remove submodulize
  )


  def self.run!
    global_opts = Trollop::options do
      version Version
      banner  "
        Manage projects saved in gitosis.

        project COMMAND [ARGS]

        Commands are:
          #{SubCommands.join( "
          ")}

        Run project COMMAND --help for command specific help.


        Global options:
      ".cleanup

      opt :name,  "
        The name of the project.  If unspecified, will default to DIR,
        if relevant for the command
      ".oneline,
        :type   => :string

      opt :gitosis_conf, "
        The location of .gitosis-conf, which also implies the location
        of the gitosis directory.
      ".oneline,
        :type   => :string,
        :default  => GitosisConf

      opt :templates_root, "
        The location of templates to create projects from.
      ".oneline,
        :type   => :string,
        :default  => TemplatesRoot

      stop_on SubCommands
    end


    cmd = ARGV.shift
    cmd_opts = Trollop::options do
      case cmd
      when "create"
        banner "
          project create DIRECTORY [TEMPLATE]

          Create a project in DIRECTORY, initialized from TEMPLATE.
          Create a git repository, add it to gitosis, and add as a
          submodule to the nearest ancestor directory that is a git
          repository (if one exists).

          Options:
        ".cleanup

        opt   :github,
              "If specified, create on github instead of gitosis",
              :type     => :boolean,
              :default  => false
      when "remove"
        banner "Not implemented"

      when "gitosis-list"
        banner "
          project gitosis-list [PATTERN]

          List groups that match PATTERN, or have writables
          that match PATTERN.  PATTERN defaults to '.*'.

          Options:
        ".cleanup

      when "gitosis-add"
        banner "
          project gitosis-add DIRECTORY

          Add DIRECTORY to gitosis.

          Options:
        ".cleanup

      when "gitosis-remove"
        banner "Not implemented"

      when "submodulize"
        banner "
          project submodulize DIRECTORY

          Add DIRECTORY as a submodule to its nearest ancestor that is
          a git repository, if such an ancestor exists.

          Options:
        ".cleanup

      else
        Trollop::die "No command specified" if cmd.nil?
        Trollop::die "Unknown command #{cmd}"
      end
    end


    opts = global_opts.merge( cmd_opts )
    case cmd 
    when "create"
      directory, template = *ARGV
      name = (opts[ :name ] ||= File.basename( directory ))

      opts[ :push ] = true
      Project::create( [directory, template], opts )

      unless opts[:github]
        Project::Gitosis::add( name, directory, opts )
      else
        Project::Github::add( name, directory, opts )
      end
      
      Project::Git::add_as_submodule( directory, opts )

    when "remove"
      Trollop::die "Not Implemented"

    when "gitosis-list"
      Project::Gitosis::list( ARGV, opts )

    when "gitosis-add"
      directory, template = *ARGV
      name = (opts[ :name ] ||= File.basename( directory ))
      Project::Gitosis::add( name, directory, opts )

    when "gitosis-remove"
      Trollop::die "Not Implemented"

    when "submodulize"
      directory, template = *ARGV
      Project::Git::add_as_submodule( directory, opts )

    else
      raise "Internal project error."
    end
  end
end
