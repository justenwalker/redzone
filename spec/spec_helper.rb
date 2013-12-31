dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, 'lib')

require 'rubygems'
require 'bundler/setup'

Bundler.require :default, :test

require 'pathname'
require 'tmpdir'

Pathname.glob("#{dir}/shared_behaviours/**/*.rb") do |behaviour|
  require behaviour.relative_path_from(Pathname.new(dir))
end

def root_path
  Pathname.new(File.expand_path(File.join(__FILE__, '..', '..')))
end

def fixture_path
  root_path + 'spec' + 'fixtures'
end

def resources_path
  root_path + 'resources'
end

RSpec.configure do |config|
  config.mock_with :mocha
end