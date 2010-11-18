class BaseApp < Sinatra::Base
  configure do
    set(:environment, :test)
    set(:root, File.dirname(__FILE__))
  end

  register Sinatra::Bundles
end