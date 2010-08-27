
namespace :version do

  def version
    y = YAML::load_file( "VERSION.yml" )
    v = {
      :major => 0, :minor => 0, :patch => 0, :build => 0
    }
    v.merge!( y ) if y.is_a? Hash
    v
  end

  desc "Write out build version.  You must supply BUILD."
  task 'write:build' do
    unless ENV.has_key? 'BUILD'
      abort "Must supply BUILD=<build> to write out build version number." 
    end
    v = version
    v[ :build ] = ENV['BUILD']
    File.open( "VERSION.yml", "w" ){|f| f.puts YAML::dump( v )}
  end

  desc "Bump build.  Assumes build version is a number."
  task 'bump:build' do
    v = version
    unless v[:build].is_a? Numeric
      if v[:build]  =~ /\d*/
        v[:build]   = v[:build].to_i
      else
        raise "Can't bump build: not a number"
      end
    end

    v[ :build ] += 1

    v.each{|k,v| ENV[ k.to_s.upcase ] = v.to_s}
    Rake::Task["version:write"].invoke
  end

end

