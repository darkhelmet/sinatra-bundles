module Sinatra
  # Main Bundles Module
  module Bundles
    mypath = File.dirname(__FILE__)
    autoload :Helpers, "#{mypath}/bundles/helpers"
    autoload :Bundle, "#{mypath}/bundles/bundle"
    autoload :JavascriptBundle, "#{mypath}/bundles/javascript_bundle"
    autoload :StylesheetBundle, "#{mypath}/bundles/stylesheet_bundle"

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
      # Setup defaults
      app.set({
        :javascript_bundles => {},
        :stylesheet_bundles => {},
        :bundle_cache_time => 60 * 60 * 24 * 365,
        :stylesheets => lambda { app.respond_to?(:css) ? app.css : 'stylesheets' },
        :javascripts => lambda { app.respond_to?(:js) ? app.js : 'javascripts' },
        :compress_bundles => false,
        :cache_bundles => false,
        :stamp_bundles => true,
        :warm_bundle_cache => true
      })

      # Production defaults
      app.configure :production do
        app.set({
          :compress_bundles => true,
          :cache_bundles => true
        })
      end

      app.helpers(Helpers)

      app.get(%r{/#{Regexp.quote(app.stylesheets)}/bundles/(\w+)(?:/(\d+))?\.css}) do |bundle, stamp| # Don't really care about the stamp.
        content_type('text/css; charset=utf-8')
        headers['Vary'] = 'Accept-Encoding'
        if settings.cache_bundles
          expires(settings.bundle_cache_time, :public, :must_revalidate)
          etag(settings.stylesheet_bundles[bundle.intern].etag)
        end
        settings.stylesheet_bundles[bundle.intern].content
      end

      app.get(%r{/#{Regexp.quote(app.javascripts)}/bundles/(\w+)(?:/(\d+))?\.js}) do |bundle, stamp| # Don't really care about the stamp.
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