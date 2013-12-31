# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redzone/version'

Gem::Specification.new do |spec|
  # Metadata
  spec.name        = 'redzone'
  spec.version     = RedZone::VERSION
  spec.authors     = ['Justen Walker']
  spec.email       = %w(justen.walker@gmail.com)
  spec.homepage    = "https://github.com/justenwalker/redzone"
  spec.summary     = 'RedZone - Automatically generate BIND zone files'
  spec.description = <<-eos.gsub(/^ +/,'')
                     RedZone is a command-line too that can generate bind zone
                     files and configuration from yaml syntax.
                     eos
  spec.license     = "MIT"


  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # Dependencies
  spec.required_ruby_version = '>= 1.8.7'
  spec.add_runtime_dependency 'thor', '~> 0.18.1'
  
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
