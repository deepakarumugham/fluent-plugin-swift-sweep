# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-swift-sweep"
  spec.version       = "0.0.1"
  spec.authors       = ["Deepak Arumugham"]
  spec.email         = ["deepak.arumugham@gmail.com"]

  spec.summary       = %q{Fluentd plugin to move local files to Swift Object storage.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/deepakarumugham/fluent-plugin-swift-sweep"
  spec.license       = "MIT"

  spec.files         = `find .`.split("\n")
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd", "~> 0.12.0"
  spec.add_dependency "fog", "~> 1.15.0"
end
