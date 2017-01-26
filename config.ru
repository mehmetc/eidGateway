$LOAD_PATH << '.'
require 'rubygems'
require 'bundler'
Bundler.setup(:default, :client)

require 'sinatra'
require 'rack/cors'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', :methods => [:post, :put], :headers => :any
  end
end

require 'app/controllers/main_controller'
require 'app/controllers/stream_controller'

map '/' do
  run MainController
end

map '/stream' do
  run StreamController
end