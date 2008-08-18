begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

# this is my favorite way to require ever
begin
  require 'mocha'
rescue LoadError
  require 'rubygems'
  gem 'mocha'
  require 'mocha'
end

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'punch'
