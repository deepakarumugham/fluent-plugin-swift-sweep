# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-swift-sweep"
  spec.version       = "0.1.3"
  spec.authors       = ["Civitaspo(takahiro.nakayama)", "Naotoshi Seo"]
  spec.email         = ["civitaspo@gmail.com", "sonots@gmail.com"]

  spec.summary       = %q{Fluentd plugin to cat files and move them.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/civitaspo/fluent-plugin-cat-sweep"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd", "~> 0.12.0"
  spec.add_dependency "fog", "~> 1.15.0"
  spec.add_dependency "yajl-ruby", "~> 1.0"
  spec.add_dependency "fluent-mixin-config-placeholders", "~> 0.2.0"
  spec.add_development_dependency "rake", ">= 0.9.2"
  spec.add_development_dependency "flexmock", ">= 1.2.0"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "test-unit-rr"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
end
