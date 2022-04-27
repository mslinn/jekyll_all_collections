# frozen_string_literal: true

require "jekyll"
require "jekyll_plugin_logger"
require_relative "jekyll_all_collections/version"

# Creates a property called site.all_collections if it does not already exist
module JekyllAllCollections
  @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)

  def maybe_compute_all_collections(site)
    @logger.debug { "JekyllAllCollections.maybe_compute_all_collections invoked" }
    return if site.class.method_defined? :all_collections

    @logger.debug { "JekyllAllCollections.maybe_compute_all_collections creating site.all_collections" }

    site.class.module_eval { attr_accessor :all_collections }
    site.all_collections =
      site.collections
          .values
          .map { |x| x.class.method_defined?(:docs) ? x.docs : x }
          .flatten
  end

  module_function :maybe_compute_all_collections

  PluginMetaLogger.instance.logger.info { "Loaded JekyllAllCollections v#{JekyllAllCollectionsVersion::VERSION} plugin." }
end
