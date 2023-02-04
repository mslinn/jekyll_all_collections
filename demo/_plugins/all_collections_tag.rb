require 'jekyll_plugin_logger'

# @author Copyright 2020 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0
module JekyllAllCollectionsTag
  PLUGIN_NAME = 'all_collections'.freeze

  class AllCollectionsTag < Liquid::Tag
    # @param tag_name [String] is the name of the tag, which we already know.
    # @param command_line [Hash, String, Liquid::Tag::Parser] the arguments from the web page.
    # @param tokens [Liquid::ParseContext] tokenized command line
    # @return [void]
    def initialize(tag_name, command_line, tokens)
      super
      @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    # @return [String]
    def render(liquid_context)
      site = liquid_context.registers[:site]
      JekyllAllCollections.compute(site) unless site.class.method_defined? :all_collections
      site.all_collections
    end
  end
end

Liquid::Template.register_tag(JekyllAllCollectionsTag::PLUGIN_NAME, JekyllAllCollectionsTag::AllCollectionsTag)
PluginMetaLogger.instance.info { "Loaded #{JekyllAllCollectionsTag::PLUGIN_NAME} v#{JekyllAllCollectionsVersion::VERSION} tag plugin." }
