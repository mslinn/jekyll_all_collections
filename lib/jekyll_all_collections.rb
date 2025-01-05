def require_directory(dir)
  Dir[File.join(dir, '*.rb')]&.sort&.each do |file|
    require file unless file == __FILE__
  end
end

require 'jekyll'
require 'jekyll_plugin_logger'
require 'jekyll_plugin_support'

require_relative 'jekyll_all_collections/version'
require_directory "#{__dir__}/hooks"
require_directory "#{__dir__}/tag"
require_directory "#{__dir__}/util"

module JekyllAllCollections
  include AllCollectionsHooks
  include AllCollectionsTag
end
