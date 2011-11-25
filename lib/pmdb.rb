require 'bundler'
Bundler.setup

require 'sinatra/base'
require 'sinatra/reloader'
require 'haml'
require 'compass'
require 'yaml'
require 'pathname'
require 'parallel'
require 'net/http'
require 'yajl'

require_relative 'pathname_ext'
require_relative 'movie_finder'
require_relative 'imdb'

class PMDb < Sinatra::Base
  helpers do
    class << self
      def pmdb_config
        YAML.load(File.read(File.dirname(__FILE__) + '/../config.yml'))
      end
    end
  end

  configure do
    Compass.configuration do |config|
      config.project_path = File.dirname(__FILE__)
      config.sass_dir = 'views'
    end

    set :haml, {:format => :html5}
    set :scss, Compass.sass_engine_options
    set :port, pmdb_config["port"]
    set(:pmdb) {pmdb_config}
    enable :logging
    disable :threaded
  end

  configure :development do
    register Sinatra::Reloader
  end

  get "/" do
    p settings.pmdb
    require "pp"
    pp MovieFinder.new(settings.pmdb).movies
    haml :index
  end

  get '/css/pmdb.css' do
    content_type 'text/css', :charset => 'utf-8'
    scss :pmdb
  end

  run! if app_file == $0
end
