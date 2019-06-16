# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative './lib/data_verifier/version.rb'

Gem::Specification.new do |s|
  s.name                        =   'data_verifier'
  s.version                     =   DataVerifier::VERSION
  s.summary                     =   'Verify data after performing series of operations'
  s.authors                     =   ['Ajit Singh']
  s.email                       =   'jeetsingh.ajit@gamil.com'
  s.license                     =   'MIT'
  s.homepage                    =   'https://github.com/ajitsing/data_verifier'

  s.files                       =   `git ls-files -z`.split("\x0")
  s.executables                 =   s.files.grep(%r{^bin/}) { |f| File.basename(f)  }
  s.test_files                  =   s.files.grep(%r{^(test|spec|features)/})
  s.require_paths               =   ["lib"]

  s.add_dependency                  'axlsx', '~> 2.0.1'
  s.add_dependency                  'sequel', '~> 5.1.0'
  s.add_development_dependency      "bundler", "~> 1.5"
  s.add_development_dependency      'rspec'
end
