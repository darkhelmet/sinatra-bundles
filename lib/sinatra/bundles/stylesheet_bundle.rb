require 'rainpress'

module Sinatra
  module Bundles
    # Bundle for stylesheets
    class StylesheetBundle < Bundle
      # Generate the HTML tag for the stylesheet
      #
      # @param [String] name The name of a bundle
      # @return [String] The HTML that can be inserted into the doc
      def to_html(name, media = :all)
        media = media.join(', ') if media.is_a? Array
        prefix = "/#{@app.stylesheets}/bundles"
        href = @app.stamp_bundles ? "#{prefix}/#{name}/#{stamp}.css" : "#{prefix}/#{name}.css"
        "<link type='text/css' href='#{href}' rel='stylesheet' media='#{media}' />"
      end

    protected

      # The root of these bundles, for path purposes
      def root
        File.join(@app.public, @app.stylesheets)
      end

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
        File.join(root, "#{filename}.css")
      end
    end
  end
end