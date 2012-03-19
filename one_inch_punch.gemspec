Gem::Specification.new do |gem|
  gem.add_development_dependency 'bacon', '>= 1.1.0'
  gem.add_development_dependency 'facon', '>= 0.5.0'
  gem.add_runtime_dependency 'timely', '>= 0.0.1'
  gem.authors = ['Yossef Mendelssohn']
  gem.description = %q{A simple time-tracking tool, compatible with Ara T. Howard's punch gem.}
  gem.email = ['ymendel@pobox.com']
  gem.executables = ['punch']
  gem.files = Dir['License.txt', 'History.txt', 'README.txt', 'lib/**/*', 'spec/**/*', 'bin/**/*']
  gem.homepage = 'http://github.com/ymendel/one_inch_punch/'
  gem.name = 'one_inch_punch'
  gem.require_paths = ['lib']
  gem.summary = %q{Track your time locally.}
  gem.version = '0.5.1'
end
