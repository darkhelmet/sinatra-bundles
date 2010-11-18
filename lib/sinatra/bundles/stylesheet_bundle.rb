require 'rainpress'

module Sinatra
  module Bundles
    # Bundle for stylesheets
    class StylesheetBundle < Bundle
      # Generate the HTML tag for the stylesheet
      #
      # @param [String] name The name of a bundle
      # @param [String] script_name The SCRIPT_NAME prefix, since we can't access it otherwise
      # @return [String] The HTML that can be inserted into the doc
      def to_html(media = :all, script_name = nil)
        media = media.join(', ') if media.is_a?(Array)
        "<link type='text/css' href='#{to_path(script_name)}' rel='stylesheet' media='#{media}' />"
      end

      # Generate the path for the CSS file
      #
      # @param [String] script_name The SCRIPT_NAME prefix, since we can't access it otherwise
      # @return [String] The path
      def to_path(script_name = nil)
        prefix = "#{script_name}/#{@app.stylesheets}/bundles"
        @app.stamp_bundles ? "#{prefix}/#{key}/#{stamp}.css" : "#{prefix}/#{key}.css"
      end

      # The root of these bundles, for path purposes
      def root
        @root ||= File.join(@app.public, @app.stylesheets)
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
        File.join(root, "#{filename}.css")
      end
    end
  end
end