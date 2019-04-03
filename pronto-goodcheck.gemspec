# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pronto/goodcheck/version"

Gem::Specification.new do |spec|
  spec.name          = "pronto-goodcheck"
  spec.version       = Pronto::Goodcheck::VERSION
  spec.authors       = ["Chris Fung"]
  spec.email         = ["aergonaut@gmail.com"]

  spec.summary       = "Pronto runner for Goodcheck"
  spec.homepage      = "https://github.com/aergonaut/pronto-goodcheck"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "goodcheck", ">= 1.5.0"
  spec.add_dependency "pronto", ">= 0.9.5"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
