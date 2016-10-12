# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'application_insights/version'

Gem::Specification.new do |spec|
  spec.name          = 'application_insights'
  spec.version       = ApplicationInsights::VERSION
  spec.authors       = ['Microsoft']
  spec.email         = ['aiengdisc@microsoft.com']
  spec.summary       = %q{Application Insights SDK for Ruby}
  spec.description   = %q{This project extends the Application Insights API surface to support Ruby.}
  spec.homepage      = 'https://github.com/Microsoft/AppInsights-Ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'yard', '~> 0.8.7.6'
  spec.add_development_dependency 'redcarpet', '~> 3.2.2'
  spec.add_development_dependency 'rack', '>= 1.0.0'
  spec.add_development_dependency 'test-unit', '~> 3.0.8'
end
