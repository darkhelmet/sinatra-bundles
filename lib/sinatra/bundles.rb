module Sinatra
  # Main Bundles Module
  module Bundles
    mypath = File.dirname(__FILE__)
    autoload :Helpers, mypath + '/bundles/helpers'
    autoload :Bundle, mypath + '/bundles/bundle'
    autoload :JavascriptBundle, mypath + '/bundles/javascript_bundle'
    autoload :StylesheetBundle, mypath + '/bundles/stylesheet_bundle'

    # Set a Javascript bundle
    #    javascript_bundle(:all, %w(jquery lightbox))
    # @param [Symbol,String] key The bundle name
    # @param [Array(String)] files The list of filenames, without extension,
    #   assumed to be in the public directory, under 'javascripts'
    def javascript_bundle(key, files = nil)
      javascript_bundles[key] = JavascriptBundle.new(self, files)
    end

    # Set a CSS bundle
    #    stylesheet_bundle(:all, %w(reset grid fonts))
    # @param [Symbol,String] key The bundle name
    # @param [Array(String)] files The list of filenames, without extension,
    #   assumed to be in the public directory, under 'stylesheets'
    def stylesheet_bundle(key, files = nil)
      stylesheet_bundles[key] = StylesheetBundle.new(self, files)
    end

    def self.registered(app)
      # Setup empty bundle containers
      app.set(:javascript_bundles, {})
      app.set(:stylesheet_bundles, {})

      # Setup defaults
      app.set(:bundle_cache_time, 60 * 60 * 24 * 365)
      app.set(:javascripts, 'javascripts')
      app.set(:stylesheets, 'stylesheets')
      app.disable(:compress_bundles)
      app.disable(:cache_bundles)
      app.enable(:stamp_bundles)
      app.enable(:warm_bundle_cache)

      # Production defaults
      app.configure :production do
        app.enable(:compress_bundles)
        app.enable(:cache_bundles)
      end

      app.helpers(Helpers)

      app.get('/'+settings.stylesheets+'/bundles/:bundle.css') do |bundle|
        content_type('text/css')
        headers['Vary'] = 'Accept-Encoding'
        if settings.cache_bundles
          expires(settings.bundle_cache_time, :public, :must_revalidate)
          etag(settings.stylesheet_bundles[bundle.intern].etag)
        end
        settings.stylesheet_bundles[bundle.intern].content
      end

      app.get('/'+settings.javascripts+'/bundles/:bundle.js') do |bundle|
        content_type('text/javascript; charset=utf-8')
        headers['Vary'] = 'Accept-Encoding'
        if settings.cache_bundles
          expires(settings.bundle_cache_time, :public, :must_revalidate)
          etag(settings.javascript_bundles[bundle.intern].etag)
        end
        settings.javascript_bundles[bundle.intern].content
      end
    end
  end

  register(Bundles)
end