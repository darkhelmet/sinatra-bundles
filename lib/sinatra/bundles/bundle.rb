require 'digest'

module Sinatra
  module Bundles
    # The base class for a bundle of files.
    # The developer user sinatra-bundles should
    # never have to deal with this directly
    class Bundle
      include Enumerable

      attr_reader :key

      def initialize(app, key, names = nil)
        @app = app
        @key = key
        @names = names || ['**/*']

        etag if @app.warm_bundle_cache
      end

      def files
        @files ||= @names.map do |f|
          full_path = path(f)
          if File.file?(full_path)
            f
          else
            ext = File.extname(full_path)
            Dir[full_path].map do |file|
              if File.exists?(file)
                file.chomp(ext).gsub("#{root}/", '')
              end
            end
          end
        end.flatten.compact.uniq
      end

      # Since we pass Bundles back as the body,
      # this follows Rack standards and supports an each method
      # to yield parts of the body, in our case, the files.
      def each
        files.each do |f|
          content = File.read(path(f))
          content = compress(content) if @app.compress_bundles
          # Include a new line to prevent weirdness at file boundaries
          yield("#{content}\n")
        end
      end

      # Returns the bundled content.
      # Cached in a local variable to prevent rebundling on future requests.
      def content
        rebundle if needs_rebundle?
        @content ||= self.to_a.join
      end

      # Returns an etag for the bundled content.
      # Cached in a local variable to prevent recomputing on future requests.
      def etag
        rebundle if needs_rebundle?
        @etag ||= Digest::MD5.hexdigest(content)
      end

      # Returns true if the content needs to be rebundled
      def needs_rebundle?
        # Right now compression is the only option that requires rebundling
        @options_hash != options_hash.hash
      end

      # Clear local variable caches effectively causing rebundling
      def rebundle
        @content = nil
        @etag = nil
        @files = nil
        @options_hash = options_hash.hash
      end

      # Set the root path for this bundle
      def root=(path)
        @root = path
        rebundle
      end

    private

      def public_folder
        @public ||= @app.respond_to?(:public_folder) ? @app.public_folder : @app.public
      end

      def options_hash
        {
          :compress => @app.compress_bundles,
          :stamp => stamp,
          :root => root
        }
      end

      # The timestamp of the bundle, which is the newest file in the bundle.
      #
      # @return [Integer] The timestamp of the bundle
      def stamp
        files.map { |f| File.mtime(path(f)) }.max.to_i
      end
    end
  end
end