# frozen_string_literal: true

require "jekyll"
require "jekyll_plugin_logger"
require_relative "jekyll_all_collections/version"

# Creates a property called site.all_collections
module JekyllAllCollections
  # @param payload [Hash] contains final values of variables after rendering the entire site (useful for sitemaps, feeds, etc).
  Jekyll::Hooks.register(:site, :post_render, priority: :high) do |site, _payload|
    @log_site.info { "Jekyll::Hooks.register(:site, :post_render) invoked." }

    site.class.module_eval { attr_accessor :all_collections}
    site.all_collections =
      site.collections
          .values
          .map { |x| x.class.method_defined?(:docs) ? x.docs : x }
          .flatten
  end

  PluginMetaLogger.instance.logger.info { "Loaded JekyllAllCollections v#{JekyllAllCollectionsVersion::VERSION} plugin." }
end
