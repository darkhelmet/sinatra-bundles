require 'rainpress'
require 'packr'

module Sinatra
  module Bundles
    class Bundle
      def initialize(app, files)
        @app = app
        @files = files
      end

      def each
        @files.each do |f|
          content = File.read(path(f))
          content = compress(content) if @app.compress_bundles
          yield("#{content}\n")
        end
      end

    private

      def stamp
        @files.map do |f|
          File.mtime(path(f))
        end.sort.first.to_i
      end
    end

    class StylesheetBundle < Bundle
      def to_html(name)
        "<link type='text/css' href='/stylesheets/bundle_#{name}.css?#{stamp}' rel='stylesheet' media='screen' />"
      end

    protected

      def compress(css)
        Rainpress.compress(css)
      end

      def path(filename)
        File.join(@app.public, 'stylesheets', "#{filename}.css")
      end
    end

    class JavascriptBundle < Bundle
      def to_html(name)
        "<script type='text/javascript' src='/javascripts/bundle_#{name}.js?#{stamp}'></script>"
      end

    protected

      def compress(js)
        Packr.pack(js, :shrink_vars => true)
      end

      def path(filename)
        File.join(@app.public, 'javascripts', "#{filename}.js")
      end
    end

    module Helpers
      def javascript_bundle_include_tag(bundle)
        options.javascript_bundles[bundle].to_html(bundle)
      end

      def stylesheet_bundle_link_tag(bundle)
        options.stylesheet_bundles[bundle].to_html(bundle)
      end
    end

    def javascript_bundle(key, files)
      javascript_bundles[key] = JavascriptBundle.new(self, files)
    end

    def stylesheet_bundle(key, files)
      stylesheet_bundles[key] = StylesheetBundle.new(self, files)
    end

    def self.registered(app)
      app.set(:javascript_bundles, {})
      app.set(:stylesheet_bundles, {})
      app.set(:bundle_cache_time, 60 * 60 * 24 * 365)
      app.disable(:compress_bundles)
      app.disable(:cache_bundles)

      app.helpers(Helpers)

      app.get('/stylesheets/bundle_:bundle.css') do |bundle|
        content_type('text/css')
        headers['Vary'] = 'Accept-Encoding'
        expires(options.bundle_cache_time, :public) if options.cache_bundles
        options.stylesheet_bundles[bundle.intern]
      end

      app.get('/javascripts/bundle_:bundle.js') do |bundle|
        content_type('text/javascript; charset=utf-8')
        headers['Vary'] = 'Accept-Encoding'
        expires(options.bundle_cache_time, :public) if options.cache_bundles
        options.javascript_bundles[bundle.intern]
      end
    end
  end

  register(Bundles)
end