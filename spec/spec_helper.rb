$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'rack/test'
require 'sinatra/base'
require 'sinatra/bundles'

RSpec.configure do |c|
  c.include Rack::Test::Methods
  c.include Sinatra::Bundles::Helpers
end
