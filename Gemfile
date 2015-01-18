source 'http://rubygems.org'
gemspec

group :development do
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-rubocop' if RUBY_VERSION >= '1.9.3'
  gem 'rb-fsevent', '~> 0.9.1'
end

platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
end
