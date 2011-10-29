require 'packr'

module Sinatra
  module Bundles
    # Bundle for javascripts
    class JavascriptBundle < Bundle
      # Generate the HTML tag for the script file
      #
      # @param [String] script_name The SCRIPT_NAME prefix, since we can't access it otherwise
      # @return [String] The HTML that can be inserted into the doc
      def to_html(script_name = nil)
        "<script type='text/javascript' src='#{to_path(script_name)}'></script>"
      end

      # Generate the path for the script file
      #
      # @param [String] script_name The SCRIPT_NAME prefix, since we can't access it otherwise
      # @return [String] The path
      def to_path(script_name = nil)
        prefix = "#{script_name}/#{@app.javascripts}/bundles"
        @app.stamp_bundles ? "#{prefix}/#{key}/#{stamp}.js" : "#{prefix}/#{key}.js"
      end

      # The root of these bundles, for path purposes
      def root
        @root ||= File.join(@app.public_folder, @app.javascripts)
      end

    protected

      # Compress Javascript
      #
      # @param [String] js The Javascript to compress
      # @return [String] Compressed Javascript
      def compress(js)
        # Don't shrink variables if the file includes a call to `eval`
        Packr.pack(js, :shrink_vars => !js.include?('eval('))
      end

      # Get the path of the file on disk
      #
      # @param [String] filename The name of sheet,
      #   assumed to be in the public directory, under 'javascripts'
      # @return [String] The full path to the file
      def path(filename)
        File.join(root, "#{filename}.js")
      end
    end
  end
end
