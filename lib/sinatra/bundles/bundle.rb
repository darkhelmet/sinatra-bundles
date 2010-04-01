module Sinatra
  module Bundles
    # The base class for a bundle of files.
    # The developer user sinatra-bundles should
    # never have to deal with this directly
    class Bundle
      include Enumerable

      def initialize(app, files = nil)
        @app = app
        @files = Array.new
        files ||= ["**"]
        files.each do |f|
          full_path = path(f)
          if File.file? full_path
            @files << f
          else
            dir = File.dirname(full_path)
            ext = File.extname(full_path)
            pattern = File.join(dir, f, "**", "*#{ext}")
            Dir.glob(pattern) do |file|
              file.chomp!(ext).slice!(0..dir.length)
              @files << file
            end
          end
        end
        @files.uniq!
        etag
        # puts @files.inspect
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

      # Returns the bundled content.
      # Cached in a local variable to prevent rebundling on future requests.
      def content
        @content ||= self.to_a.join('')
      end

      # Returns an etag for the bundled content.
      # Cached in a local variable to prevent recomputing on future requests.
      def etag
        @etag ||= Digest::MD5.hexdigest(content)
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
  end
end