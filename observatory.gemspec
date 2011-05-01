# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'observatory'

Gem::Specification.new do |s|
  s.name        = 'observatory'
  s.version     = Observatory::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Arjan van der Gaag']
  s.email       = ['arjan@arjanvandergaag.nl']
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = 'observatory'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency 'yard',      '~>0.6'
  s.add_development_dependency 'bluecloth', '~>2.1'
  s.add_development_dependency 'rake',      '~>0.8'
end
