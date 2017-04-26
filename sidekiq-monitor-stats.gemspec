# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-monitor-stats"
  spec.version       = "0.0.1"
  spec.authors       = ["Albert Llop"]
  spec.email         = ["albert@getharvest.com"]
  spec.summary       = %q{Add an endpoint to your running application that is running Sidekiq that returns useful data in JSON format.}
  spec.homepage      = "https://github.com/harvesthq/sidekiq-monitor-stats"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", ">= 5.0.0"
  spec.add_development_dependency "sinatra"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "appraisal"
  spec.add_dependency "sidekiq"
end
