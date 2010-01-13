require 'rainpress'
require 'packr'

module Sinatra
  # Main Bundles Module
  module Bundles
    # The base class for a bundle of files.
    # The developer user sinatra-bundles should
    # never have to deal with this directly
    class Bundle
      def initialize(app, files)
        @app = app
        @files = files
      end

      # Since we pass Bundles back as the body,
      # this follows Rack standards and supports an each method
      # to yield parts of the body, in our case, the files.
      def each
        @files.each do |f|
          content = File.read(path(f))
          content = compress(content) if @app.compress_bundles
          # Include a new line to prevent weirdness at file boundaries
          yield("#{content}\n")
        end
      end

    private

      # The timestamp of the bundle, which is the newest file in the bundle.
      #
      # @return [Integer] The timestamp of the bundle
      def stamp
        @files.map do |f|
          File.mtime(path(f))
        end.sort.first.to_i
      end
    end

    # Bundle for stylesheets
    class StylesheetBundle < Bundle
      # Generate the HTML tag for the stylesheet
      #
      # @param [String] name The name of a bundle
      # @return [String] The HTML that can be inserted into the doc
      def to_html(name)
        "<link type='text/css' href='/stylesheets/bundle_#{name}.css#{@app.stamp_bundles ? "?#{stamp}" : ''}' rel='stylesheet' media='screen' />"
      end

    protected

      # Compress CSS
      #
      # @param [String] css The CSS to compress
      # @return [String] Compressed CSS
      def compress(css)
        Rainpress.compress(css)
      end

      # Get the path of the file on disk
      #
      # @param [String] filename The name of sheet,
      #   assumed to be in the public directory, under 'stylesheets'
      # @return [String] The full path to the file
      def path(filename)
        File.join(@app.public, 'stylesheets', "#{filename}.css")
      end
    end

    # Bundle for javascripts
    class JavascriptBundle < Bundle
      # Generate the HTML tag for the script file
      #
      # @param [String] name The name of a bundle
      # @return [String] The HTML that can be inserted into the doc
      def to_html(name)
        "<script type='text/javascript' src='/javascripts/bundle_#{name}.js#{@app.stamp_bundles ? "?#{stamp}" : ''}'></script>"
      end

    protected

      # Compress Javascript
      #
      # @param [String] js The Javascript to compress
      # @return [String] Compressed Javascript
      def compress(js)
        Packr.pack(js, :shrink_vars => true)
      end

      # Get the path of the file on disk
      #
      # @param [String] filename The name of sheet,
      #   assumed to be in the public directory, under 'javascripts'
      # @return [String] The full path to the file
      def path(filename)
        File.join(@app.public, 'javascripts', "#{filename}.js")
      end
    end

    # View helpers
    module Helpers
      # Emit a script tag for a javascript bundle
      #
      # @param [Symbol,String] bundle The bundle name
      # @return [String] HTML script tag
      def javascript_bundle_include_tag(bundle)
        options.javascript_bundles[bundle].to_html(bundle)
      end

      # Emit a script tag for a stylesheet bundle
      #
      # @param [Symbol,String] bundle The bundle name
      # @return [String] HTML link tag
      def stylesheet_bundle_link_tag(bundle)
        options.stylesheet_bundles[bundle].to_html(bundle)
      end
    end

    # Set a Javascript bundle
    #    javascript_bundle(:all, %w(jquery lightbox))
    # @param [Symbol,String] key The bundle name
    # @param [Array(String)] files The list of filenames, without extension,
    #   assumed to be in the public directory, under 'javascripts'
    def javascript_bundle(key, files)
      javascript_bundles[key] = JavascriptBundle.new(self, files)
    end

    # Set a CSS bundle
    #    stylesheet_bundle(:all, %w(reset grid fonts))
    # @param [Symbol,String] key The bundle name
    # @param [Array(String)] files The list of filenames, without extension,
    #   assumed to be in the public directory, under 'stylesheets'
    def stylesheet_bundle(key, files)
      stylesheet_bundles[key] = StylesheetBundle.new(self, files)
    end

    def self.registered(app)
      # Setup empty bundle containers
      app.set(:javascript_bundles, {})
      app.set(:stylesheet_bundles, {})

      # Setup defaults
      app.set(:bundle_cache_time, 60 * 60 * 24 * 365)
      app.disable(:compress_bundles)
      app.disable(:cache_bundles)
      app.enable(:stamp_bundles)

      # Production defaults
      app.configure :production do
        app.enable(:compress_bundles)
        app.enable(:cache_bundles)
      end

      app.helpers(Helpers)

      app.get('/stylesheets/bundle_:bundle.css') do |bundle|
        content_type('text/css')
        headers['Vary'] = 'Accept-Encoding'
        expires(options.bundle_cache_time, :public, :must_revalidate) if options.cache_bundles
        options.stylesheet_bundles[bundle.intern]
      end

      app.get('/javascripts/bundle_:bundle.js') do |bundle|
        content_type('text/javascript; charset=utf-8')
        headers['Vary'] = 'Accept-Encoding'
        expires(options.bundle_cache_time, :public, :must_revalidate) if options.cache_bundles
        options.javascript_bundles[bundle.intern]
      end
    end
  end

  register(Bundles)
end