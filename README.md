sinatra-bundles
===============

An easy way to bundle CSS and Javascript assets in your sinatra application.

* Documentation: [http://yardoc.org/docs/darkhelmet-sinatra-bundles](http://yardoc.org/docs/darkhelmet-sinatra-bundles)

Usage
-----

sinatra-bundles combines Javascript and CSS into one file. Meaning, you can bundle 2 or more Javascript files into one, similar with CSS stylesheets. Any bundled files are expected to be in the public directory, under 'javascripts' and 'stylesheets'

Assuming you have the following files in public:

    ./stylesheets/reset.css
    ./stylesheets/fonts.css
    ./stylesheets/grid.css
    ./javascripts/jquery.js
    ./javascripts/lightbox.js
    ./javascripts/blog.js

You can bundle these files in your app like this. First, install the gem

    % [sudo] gem install sinatra-bundles

And include it in your app:

    require 'sinatra'
    require 'sinatra/bundles'

    stylesheet_bundle(:all, %w(reset fonts grid))
    javascript_bundle(:all, %w(jquery lightbox blog))

    get '/' do
      'sinatra-bundles rocks!'
    end

Then in your view, you can use the view helpers to insert the proper script tags:

    = javascript_bundle_include_tag(:all)
    = stylesheet_bundle_link_tag(:all)

All 6 of those files will be served up in 2 files, and they'll be compressed and have headers and etags set for caching.

You can also use wildcard splats.

    = javascript_bundle(:test, %w(test/*))

That will grab all files in the test directory.

    = javascript_bundle(:test, %w(test/**/*))

That will grab all files under the test directory recursively. If you don't specify any files, it defaults to 'all files' recursively.

    = javascript_bundle(:all)

Configuration
-------------

The defaults are pretty good. In development/test mode:

    bundle_cache_time # => 60 * 60 * 24 * 365, or 1 year (length of time a bundle will be cached for)
    compress_bundles # => false (compress CSS and Javascript using packr and rainpress)
    cache_bundles # => false (set caching headers)
    stamp_bundles # => true (append a timestamp to the URL as a query param)
    warm_bundle_cache # => false (generate bundle when it is defined)

And in production mode, compression and caching are enabled

    compress_bundles # => true
    cache_bundles # => true

To change any of these, use set/enable/disable

    require 'sinatra'
    require 'sinatra/bundles'

    stylesheet_bundle(:all, %w(reset fonts grid))
    javascript_bundle(:all, %w(jquery lightbox blog))

    disable(:compress_bundles)
    enable(:cache_bundles)
    set(:bundle_cache_time, 60 * 60 * 24)
    disable(:stamp_bundles)

    get '/' do
      'sinatra-bundles rocks!'
    end

Examples
--------

Check out the code for my blog for a real example: [darkblog on github](http://github.com/darkhelmet/darkblog)

What you Need
-------------

    sinatra >= 1.0
    packr
    rainpress

Note on Patches/Pull Requests
-----------------------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Thanks!
-------

* [Patrick Hogan](http://github.com/pbhogan)
  * Etag support (with specs!)
  * Wildcard globbing

Copyright
---------

Copyright (c) 2010 Daniel Huckstep. See LICENSE for details.
