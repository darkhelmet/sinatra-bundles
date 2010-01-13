require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'app'
require 'production_app'

describe 'SinatraBundles' do
  def app(env = :test)
    case env
    when :production
      ProductionApp
    else
      TestApp
    end
  end

  def stamp(type, names)
    names.map do |name|
      File.expand_path(File.join(File.dirname(__FILE__), 'public', type, "#{name}.css"))
    end.map do |path|
      File.mtime(path)
    end.sort.first.to_i
  end

  def js_stamp(names)
    stamp('javascripts', names)
  end

  def css_stamp(names)
    stamp('stylesheets', names)
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
      app.javascript_bundle(:all, %w(foo bar baz))
      app.javascript_bundles.should_not == {}
      app.javascript_bundles[:all].should be_a_kind_of(Sinatra::Bundles::Bundle)
    end
  end

  context 'stylesheet bundles' do
    it 'should create a tag without a stamp if stamps are disabled' do
      app.new.instance_eval do
        stylesheet_bundle_link_tag(:test)
      end.should == "<link type='text/css' href='/stylesheets/bundle_test.css?#{css_stamp(%w(test1 test2))}' rel='stylesheet' media='screen' />"
    end
  end
end
