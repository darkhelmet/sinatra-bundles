# -*- encoding: utf-8 -*-

## This is the rakegem gemspec template. Make sure you read and understand
## all of the comments. Some sections require modification, and others can
## be deleted if you don't need them. Once you understand the contents of
## this file, feel free to delete any comments that begin with two hash marks.
## You can find comprehensive Gem::Specification documentation, at
## http://docs.rubygems.org/read/chapter/20
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  ## Leave these as is they will be modified for you by the rake gemspec task.
  ## If your rubyforge_project name is different, then edit it and comment out
  ## the sub! line in the Rakefile
  s.name              = 'sinatra-bundles'
  s.version           = '0.5.0'
  s.date              = '2010-11-18'

  ## Make sure your summary is short. The description may be as long
  ## as you like.
  s.summary     = %q{Easy asset bundling for sinatra}
  s.description = %q{Bundle CSS and Javascript assets to a single file, compress, and cache them for snappier web experiences.}

  ## List the primary authors. If there are a bunch of authors, it's probably
  ## better to set the email to an email list or something. If you don't have
  ## a custom homepage, consider using your GitHub URL or the like.
  s.authors  = ["Daniel Huckstep"]
  s.email    = 'darkhelmet@darkhelmetlive.com'
  s.homepage = 'http://github.com/darkhelmet/sinatra-bundles'

  ## This gets added to the $LOAD_PATH so that 'lib/NAME.rb' can be required as
  ## require 'NAME.rb' or'/lib/NAME/file.rb' can be as require 'NAME/file.rb'
  s.require_paths = %w[lib]

  ## List your runtime dependencies here. Runtime dependencies are those
  ## that are needed for an end user to actually USE your code.
  s.add_dependency('rainpress', ['~> 1.0'])
  s.add_dependency('packr', ['~> 3.1.0'])
  s.add_dependency('rack', ['~> 1.0'])
  s.add_dependency('sinatra', ['~> 1.1.0'])

  ## List your development dependencies here. Development dependencies are
  ## those that are only needed during development
  s.add_development_dependency('rspec', ['~> 1.3.0'])
  s.add_development_dependency('rack-test', ['>= 0.5.3'])
  s.add_development_dependency('yard')

  ## Leave this section as-is. It will be automatically generated from the
  ## contents of your Git repository via the gemspec task. DO NOT REMOVE
  ## THE MANIFEST COMMENTS, they are used as delimiters by the task.
  # = MANIFEST =
  s.files = %w[
    Gemfile
    Gemfile.lock
    LICENSE
    README.md
    Rakefile
    VERSION
    lib/sinatra/bundles.rb
    lib/sinatra/bundles/bundle.rb
    lib/sinatra/bundles/helpers.rb
    lib/sinatra/bundles/javascript_bundle.rb
    lib/sinatra/bundles/stylesheet_bundle.rb
    sinatra-bundles.gemspec
    spec/app.rb
    spec/base_app.rb
    spec/custom_app.rb
    spec/extension_app.rb
    spec/other_public/css/test.css
    spec/other_public/javascripts/test.js
    spec/production_app.rb
    spec/public/javascripts/eval.js
    spec/public/javascripts/splat/splat.js
    spec/public/javascripts/test1.js
    spec/public/javascripts/test2.js
    spec/public/s/css
    spec/public/s/js
    spec/public/stylesheets/test1.css
    spec/public/stylesheets/test2.css
    spec/sinatra-bundles_spec.rb
    spec/spec.opts
    spec/spec_helper.rb
  ]
  # = MANIFEST =

  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  s.test_files = s.files.select { |path| path =~ /^spec\/.*\.rb/ }
end