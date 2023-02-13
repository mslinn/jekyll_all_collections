require_relative 'lib/jekyll_all_collections/version'

Gem::Specification.new do |spec|
  github = 'https://github.com/mslinn/jekyll_all_collections'

  spec.authors = ['Mike Slinn']
  spec.bindir = 'bin'
  spec.description = <<~END_OF_DESC
    Provides a collection of all collections in site.all_collections.
  END_OF_DESC
  spec.email = ['email@email.com']
  spec.executables = []

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['.rubocop.yml', 'LICENSE.*', 'Rakefile', "{lib,spec}/**/*", "*.gemspec", "*.md"]

  spec.homepage = 'https://www.mslinn.com/blog/2020/12/30/jekyll-plugin-template-collection.html'
  spec.license = 'MIT'
  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => "#{github}/issues",
    'changelog_uri'     => "#{github}/CHANGELOG.md",
    'homepage_uri'      => spec.homepage,
    'source_code_uri'   => github,
  }
  spec.name = 'jekyll_all_collections'
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.6.0'
  spec.summary = 'Provides a collection of all collections in site.all_collections.'
  spec.version = JekyllAllCollectionsVersion::VERSION

  spec.add_dependency 'jekyll', '>= 3.5.0'
  spec.add_dependency 'jekyll_draft', '~>1.1.0'
  spec.add_dependency 'jekyll_plugin_support', '~> 0.4.0'
end
