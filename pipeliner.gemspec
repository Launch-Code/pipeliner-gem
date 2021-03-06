# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pipeliner/version'

Gem::Specification.new do |spec|
  spec.name          = "pipeliner"
  spec.version       = Pipeliner::VERSION
  spec.authors       = ["Mike Menne"]
  spec.email         = ["mike@launchcode.org"]

  #if spec.respond_to?(:metadata)
  #  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  #end

  spec.summary       = %q{Gem that allows us to pull from Pipeliner stupid REST API}
  spec.description   = %q{Gem that allows us to pull from Pipeliner stupid REST API}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
	spec.add_development_dependency "pry-doc"
	spec.add_development_dependency "pry-byebug"
	spec.add_dependency "httparty", "~> 0.13.1"
	spec.add_dependency "typhoeus"
end
