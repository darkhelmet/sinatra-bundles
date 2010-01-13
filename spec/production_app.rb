gem 'sinatra', '>= 0.10.1'
require 'sinatra/base'
require 'sinatra/bundles'

class ProductionApp < Sinatra::Base
  configure do
    set(:root, File.dirname(__FILE__))
    set(:environment, :production)
  end

  register Sinatra::Bundles
end