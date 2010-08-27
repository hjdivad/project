require 'cgi'
require 'net/http'
require 'yaml'

module Project; end
module Project::Github

  def self.github_create( name, user, token )
    path = "/api/v2/yaml/repos/create"
    params = {
      :name         => name,
      :public       => 1,

      :login        => user,
      :token        => token,
    }
    post( path, params )
  end

  def self.add( name, directory, opts={} )
    user, token = `git config github.user`.chomp, `git config github.token`.chomp
    github_create( name, user, token )
    github_url = "git@github.com:#{user}/#{name}.git"

    system "
      cd #{directory}
      && git remote | grep -q origin
      || git remote add origin #{github_url}
      && git config branch.master.remote origin
      && git config branch.master.merge refs/heads/master
      && git push origin master
    ".gsub( "\n", " " )
  end


  def self.post( path, params={} )
    http = Net::HTTP.new( 'github.com', 443 )
    http.use_ssl = true
    res = nil
    http.start do
      req = Net::HTTP::Post.new( path )
      req.body = params.map{|k,v| "#{CGI.escape k.to_s}=#{CGI.escape v.to_s}"}.join("&")
      res = YAML.load http.request( req ).body
    end

    raise res["error"] if res["error"]
    res
  end
end
