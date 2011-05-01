require 'test/unit'
require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)

class Test::Unit::TestCase
  include Observatory
end