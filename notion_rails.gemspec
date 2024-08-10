# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'notion_rails'
  spec.version = '0.1.0'
  spec.authors = ['Guillermo Aguirre']
  spec.email = ['guillermoaguirre@hey.com']

  spec.summary = 'Notion HTML renderer for Rails'
  spec.description = 'Simple gem to render Notion blocks as HTML using Rails'
  spec.homepage = 'https://github.com/guillermoap/notion-rails'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/guillermoap/notion-rails'

  spec.files = Dir['LICENSE.txt', 'README.md', 'lib/**/*', 'lib/notion_rails.rb']
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'dry-configurable', '~> 1.2'
  spec.add_dependency 'rails', '~> 7.0.0'
  spec.add_dependency 'notion-ruby-client', '~> 1.2.2'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end