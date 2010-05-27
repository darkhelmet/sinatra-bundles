require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'app'
require 'production_app'
require 'custom_app'

describe 'sinatra-bundles' do
  def app(env = :test)
    case env
    when :production
      ProductionApp
    when :custom
      CustomApp
    else
      TestApp
    end
  end

  def stamp(type, ext, names)
    names.map do |name|
      File.expand_path(File.join(File.dirname(__FILE__), 'public', type, "#{name}.#{ext}"))
    end.map do |path|
      File.mtime(path)
    end.sort.first.to_i
  end

  def js_stamp(names)
    stamp('javascripts', 'js', names)
  end

  def css_stamp(names)
    stamp('stylesheets', 'css', names)
  end

  before do
    @scripts = %w(eval splat/splat test1 test2).map do |name|
      File.expand_path(File.join(File.dirname(__FILE__), 'public', 'javascripts', "#{name}.js"))
    end

    @styles = %w(test1 test2).map do |name|
      File.expand_path(File.join(File.dirname(__FILE__), 'public', 'stylesheets', "#{name}.css"))
    end
  end

  before(:each) do
    # reset defaults
    app.set(:bundle_cache_time, 60 * 60 * 24 * 365)
    app.disable(:compress_bundles)
    app.disable(:cache_bundles)
    app.enable(:stamp_bundles)
  end

  context 'settings' do
    it 'should not cache by default' do
      app.cache_bundles.should be_false
    end

    it 'should not compress by default' do
      app.compress_bundles.should be_false
    end

    it 'should cache by default in production mode' do
      app(:production).environment.should == :production
      app(:production).cache_bundles.should be_true
    end

    it 'should compress by default in production mode' do
      app(:production).environment.should == :production
      app(:production).compress_bundles.should be_true
    end

    it 'should cache for 1 year by default' do
      app.bundle_cache_time.should == (60 * 60 * 24 * 365)
    end

    it 'should timestamp by default' do
      app.stamp_bundles.should be_true
    end
  end

  context 'javascript bundles' do
    it 'should be able to set bundles' do
      app.javascript_bundle(:foo, %w(foo bar baz))
      app.javascript_bundles.should_not == {}
      app.javascript_bundles[:foo].should be_a_kind_of(Sinatra::Bundles::Bundle)
    end

    it 'should create a tag without a stamp if stamps are disabled' do
      app.new.instance_eval do
        options.disable(:stamp_bundles)
        javascript_bundle_include_tag(:test)
      end.should == "<script type='text/javascript' src='/javascripts/bundles/test.js'></script>"
    end
    it 'should create cusomized tag if path is customized' do
      app(:custom).new.instance_eval do
        options.disable(:stamp_bundles)
        javascript_bundle_include_tag(:test)
      end.should == "<script type='text/javascript' src='/s/js/bundles/test.js'></script>"
    end

    it 'should stamp bundles with the timestamp of the newest file in the bundle' do
      app.new.instance_eval do
        javascript_bundle_include_tag(:test)
      end.should == "<script type='text/javascript' src='/javascripts/bundles/test.js?#{js_stamp(%w(test1 test2))}'></script>"
    end

    it 'should serve bundles' do
      get "/javascripts/bundles/test.js"
      last_response.should be_ok
    end

    it 'should concat files in order with newlines including one at the end' do
      get '/javascripts/bundles/test.js'
      last_response.body.should == @scripts.reject { |s| s.include?('splat') }.map { |path| File.read(path) }.join("\n") + "\n"
    end

    it 'should set cache headers' do
      app.enable(:cache_bundles)
      get '/javascripts/bundles/test.js'
      last_response.should be_ok
      last_response.headers['Vary'].should == 'Accept-Encoding'
      last_response.headers['Cache-Control'].should == 'public, must-revalidate, max-age=31536000'
      last_response.headers['Etag'].should == '"4f647cfd3ab71800da1b0d0b127e2cd4"'
    end

    it 'should not shrink vars on javascript files that use eval' do
      app.enable(:compress_bundles)
      get '/javascripts/bundles/test.js'
      last_response.should be_ok
      js = File.read(File.join(File.dirname(__FILE__), 'public/javascripts/eval.js'))
      last_response.body.include?(Packr.pack(js)).should be_true
      last_response.body.include?(Packr.pack(js, :shrink_vars => true)).should be_false
    end

    it 'should handle wildcard splats for bundles' do
      get '/javascripts/bundles/test2.js'
      last_response.should be_ok
      last_response.body.include?('eval').should be_false
      last_response.body.should == @scripts.reject { |s| s.match(/eval|splat/) }.sort.map { |path| File.read(path) }.join("\n") + "\n"
    end

    it 'should handle the all scripts wildcard' do
      get '/javascripts/bundles/all.js'
      last_response.should be_ok
      last_response.body.should == @scripts.sort.map { |path| File.read(path) }.join("\n") + "\n"
    end
  end

  context 'stylesheet bundles' do
    it 'should be able to set bundles' do
      app.stylesheet_bundle(:all, %w(foo bar baz))
      app.stylesheet_bundles.should_not == {}
      app.stylesheet_bundles[:all].should be_a_kind_of(Sinatra::Bundles::Bundle)
    end

    it 'should create a tag without a stamp if stamps are disabled' do
      app.new.instance_eval do
        options.disable(:stamp_bundles)
        stylesheet_bundle_link_tag(:test)
      end.should == "<link type='text/css' href='/stylesheets/bundles/test.css' rel='stylesheet' media='all' />"
    end

    it 'should stamp bundles with the timestamp of the newest file in the bundle' do
      app.new.instance_eval do
        stylesheet_bundle_link_tag(:test)
      end.should == "<link type='text/css' href='/stylesheets/bundles/test.css?#{css_stamp(%w(test1 test2))}' rel='stylesheet' media='all' />"
    end

    it 'should create a tag with default media attribute set to all' do
      app.new.instance_eval do
        stylesheet_bundle_link_tag(:test)
      end.include?("media='all'").should be_true
    end

    it 'should create a tag with specified media attributes' do
      app.new.instance_eval do
        stylesheet_bundle_link_tag(:test, [:screen, :print])
      end.include?("media='screen, print'").should be_true
    end

    it 'should serve bundles' do
      get "/stylesheets/bundles/test.css"
      last_response.should be_ok
    end

    it 'should concat files in order with newlines including one at the end' do
      get '/stylesheets/bundles/test.css'
      last_response.body.should == @styles.map { |path| File.read(path) }.join("\n") + "\n"
    end

    it 'should set cache headers' do
      app.enable(:cache_bundles)
      get '/stylesheets/bundles/test.css'
      last_response.should be_ok
      last_response.headers['Vary'].should == 'Accept-Encoding'
      last_response.headers['Cache-Control'].should == 'public, must-revalidate, max-age=31536000'
      last_response.headers['Etag'].should == '"6ecd0946412b76dcd1eaa341cdfefa8b"'
    end
  end
end
