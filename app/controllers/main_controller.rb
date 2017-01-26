#encoding:UTF-8
require_relative 'generic_controller'

class MainController < GenericController
  get '/' do
    erb :'index.html'
  end
end