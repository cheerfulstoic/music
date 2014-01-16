# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "music/version"

Gem::Specification.new do |s|
  # Basic Info
  s.name          = "music"
  s.version       = Music::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Brian Underwood"]
  s.email         = ["ml+musicgem@semi-sentient.com"]
  s.homepage      = "http://github.com/cheerfulstoic/music"
  s.summary       = %q{Library for performing calculations on musical elements}
  s.description   = %q{Library for classifying notes and chords and performing calculations on them.  See README.md}
  s.license       = %q{MIT}

  # Files
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,factories}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Dependencies
  s.add_development_dependency  "rake", "~> 0.9"
  s.add_development_dependency  "bundler", "~> 1.2.4"
  s.add_development_dependency  "rspec", '~> 2'
end
