require_relative 'lib/jekyll_all_collections/version'

Gem::Specification.new do |spec|
  github = 'https://github.com/mslinn/jekyll_all_collections'

  spec.authors     = ['Mike Slinn']
  spec.description = <<~END_OF_DESC
    This gem is obsolete; it has been incorporated into the jekyll_plugin_support gem.
  END_OF_DESC
  spec.email    = ['mslinn@mslinn.com']
  spec.files    = Dir['.rubocop.yml', 'LICENSE.*', 'Rakefile', 'lib/**/*', '*.gemspec', '*.md']
  spec.homepage = 'https://www.mslinn.com/jekyll_plugins/jekyll_all_collections.html'
  spec.license  = 'MIT'
  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => "#{github}/issues",
    'changelog_uri'     => "#{github}/CHANGELOG.md",
    'homepage_uri'      => spec.homepage,
    'source_code_uri'   => github,
  }
  spec.name                  = 'jekyll_all_collections'
  spec.platform              = Gem::Platform::RUBY
  spec.require_paths         = ['lib']
  spec.required_ruby_version = '>= 2.6.0'
  spec.summary               = 'This gem is obsolete; it has been incorporated into the jekyll_plugin_support gem.'
  spec.version               = JekyllAllCollectionsVersion::VERSION

  spec.add_dependency 'jekyll', '>= 3.5.0'
end
