# I don't know why dose occur errors below.
#  require_relative 'lib/striuct/version'
require File.expand_path('../lib/striuct/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Kenichi Kamiya']
  gem.email         = ['kachick1+ruby@gmail.com']
  gem.summary       = %q{Struct++}
  gem.description   = %q{validatable, inheritable, And more Struct++ features :)}
  gem.homepage      = 'https://github.com/kachick/striuct'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'striuct'
  gem.require_paths = ['lib']
  gem.version       = Striuct::VERSION.dup # dup for https://github.com/rubygems/rubygems/commit/48f1d869510dcd325d6566df7d0147a086905380#-P0

  gem.required_ruby_version = '>=1.9.2'
  gem.add_runtime_dependency 'validation', '~>0.0.3'
  gem.add_runtime_dependency 'keyvalidatable', '~>0.0.2'
  gem.add_development_dependency 'yard', '>=0.8.2.1'
end

