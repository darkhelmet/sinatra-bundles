$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'spec'
require 'spec/autorun'
require 'rack/test'

gem 'sinatra', '>= 0.10.1'
require 'sinatra/base'
require 'sinatra/bundles'

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods
  config.include Sinatra::Bundles::Helpers
end
