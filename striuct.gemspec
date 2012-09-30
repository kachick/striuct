Gem::Specification.new do |gem|
  gem.authors       = ['Kenichi Kamiya']
  gem.email         = ['kachick1+ruby@gmail.com']
  gem.summary       = %q{Struct++}
  gem.description   = %q{Validatable, Inheritable... And more Struct++ features :)}
  gem.homepage      = 'https://github.com/kachick/striuct'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'striuct'
  gem.require_paths = ['lib']
  gem.version       = '0.4.0.a'

  gem.required_ruby_version = '>= 1.9.2'

  gem.add_runtime_dependency 'validation', '~> 0.0.3'
  gem.add_runtime_dependency 'optionalargument', '~> 0.0.3'
  gem.add_runtime_dependency 'keyvalidatable', '~> 0.0.3'

  gem.add_development_dependency 'yard', '~> 0.8'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
end

