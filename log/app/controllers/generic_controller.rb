#encoding:UTF-8
require 'sinatra'
require 'sinatra/streaming'
require 'multi_json'
require 'lib/event_manager'

class GenericController < Sinatra::Base
  helpers Sinatra::Streaming

  configure do

    set :root, File.absolute_path("#{File.dirname(__FILE__)}/../../")
    set :views, Proc.new { "#{root}/app/views" }

    set :method_override, true # make a PUT, DELETE possible with the _method parameter
    set :show_exceptions, false
    set :raise_errors, false
    set :logging, true
    set :static, true

    set connections: []
    set :event_manager, EventManager.new(connections)
  end

  not_found do
    message = { status: 404, body: "not found #{body.join("\n")}"}
    logger.error(message)
    message.to_json
  end

  error do
    message = { status:500, body: "error: " + env['sinatra.error'].to_s}
    logger.error(message)
    message.to_json
  end
end