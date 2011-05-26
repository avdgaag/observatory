# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'observatory'

Gem::Specification.new do |s|
  s.name        = 'observatory'
  s.version     = Observatory::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Arjan van der Gaag']
  s.email       = ['arjan@arjanvandergaag.nl']
  s.homepage    = 'http://avdgaag.github.com/observatory'
  s.summary     = "A simple implementation of the observer pattern for Ruby programs."
  s.description = %q{Observatory is a simple gem to facilitate loosely-coupled communication between Ruby objects. It implements the observer design pattern so that your objects can publish events that other objects can subscribe to. Observatory provides some syntactic sugar and methods to notify events, filter values and allow observing objects to stop the filter chain. Observatory is inspired by the Event Dispatcher Symfony component.}

  s.rubyforge_project = 'observatory'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'yard',      '~>0.7'
  s.add_development_dependency 'bluecloth', '~>2.1'
  s.add_development_dependency 'rake',      '~>0.9'
end
