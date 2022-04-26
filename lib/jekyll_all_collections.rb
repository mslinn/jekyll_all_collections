# frozen_string_literal: true

require "jekyll"
require "jekyll_plugin_logger"
require_relative "jekyll_all_collections/version"

# Creates a property called site.all_collections
module JekyllAllCollections
  # @param payload [Hash] contains final values of variables after rendering the entire site (useful for sitemaps, feeds, etc).
  Jekyll::Hooks.register(:site, :post_render, priority: :high) do |site, _payload|
    @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
    @logger.info { "JekyllAllCollections invoked Jekyll::Hooks.register(:site, :pre_render, priority: :high)." }

    site.class.module_eval { attr_accessor :all_collections }
    site.all_collections =
      site.collections
          .values
          .map { |x| x.class.method_defined?(:docs) ? x.docs : x }
          .flatten
  end

  Jekyll::Hooks.register(:site, :post_write) do |site|
    _x = site.all_collections
    puts "site.all_collections exists".red
  end

  PluginMetaLogger.instance.logger.info { "Loaded JekyllAllCollections v#{JekyllAllCollectionsVersion::VERSION} plugin." }
end
