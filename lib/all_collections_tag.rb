# require 'key_value_parser'
require 'jekyll_plugin_logger'
require 'jekyll_draft'
# require 'shellwords'

# @author Copyright 2020 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0
module AllCollectionsTag
  PLUGIN_NAME = 'all_collections'.freeze

  class AllCollectionsTag < Liquid::Tag
    # @param tag_name [String] is the name of the tag, which we already know.
    # @param command_line [Hash, String, Liquid::Tag::Parser] the arguments from the web page.
    # @param tokens [Liquid::ParseContext] tokenized command line
    # @return [void]
    def initialize(tag_name, command_line, tokens)
      super
      @command_line = command_line.strip
      @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    # @return [String]
    def render(liquid_context)
      @site = liquid_context.registers[:site]
      AllCollectionsHooks.compute(@site) unless @site.class.method_defined? :all_collections
      sort_by_age
    end

    def sort_by_age
      <<~END_TEXT
        <h2 id="posts">Posts Sorted By Age</h2>
        <div class="posts">
        #{(@site.all_collections.map do |post|
             draft = Jekyll::Draft.draft_html post
             date = post.data['date'].strftime('%Y-%m-%d')
             href = "<a href='#{post.url}'>#{post.title}</a>"
             "  <span>#{date}</span><span>#{href}#{draft}</span>"
           end).join("\n")}
        </div>
      END_TEXT
    end
  end
end

Liquid::Template.register_tag(AllCollectionsTag::PLUGIN_NAME, AllCollectionsTag::AllCollectionsTag)
PluginMetaLogger.instance.info { "Loaded #{AllCollectionsTag::PLUGIN_NAME} v#{JekyllAllCollectionsVersion::VERSION} tag plugin." }
