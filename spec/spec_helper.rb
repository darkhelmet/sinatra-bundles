$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
ENV['GEM_HOME'] = File.expand_path(File.join(File.dirname(__FILE__), '..', 'vendor'))
Gem.clear_paths
require 'spec'
require 'spec/autorun'
require 'rack/test'

gem 'sinatra', '>= 1.0.a'
require 'sinatra/base'
require 'sinatra/bundles'

Spec::Runner.configure do |c|
  c.include Rack::Test::Methods
  c.include Sinatra::Bundles::Helpers
end
