class ExtensionApp < Sinatra::Base
  configure do
    set(:environment, :test)
    set(:root, File.dirname(__FILE__))
  end

  register Sinatra::Bundles

  stylesheet_bundle(:test, %w(test)).root = File.join(File.dirname(__FILE__), 'other_public', 'css')
  javascript_bundle(:test, %w(test)).root = File.join(File.dirname(__FILE__), 'other_public', 'javascripts')
end