require 'jekyll_draft'
require 'jekyll_plugin_logger'
require 'jekyll_plugin_support'

# @author Copyright 2020 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0
module AllCollectionsTag
  PLUGIN_NAME = 'all_collections'.freeze

  class AllCollectionsTag < JekyllSupport::JekyllTag
    # Method prescribed by JekyllTag.
    # @return [String]
    def render_impl
      AllCollectionsHooks.compute(@site) unless @site.class.method_defined? :all_collections
      sort_by_age
    end

    def sort_by_age
      <<~END_TEXT
        <h2 id="posts">Posts Sorted By Age</h2>
        <div class="posts">
        #{(@site.all_collections.sort_by(&:date).map do |post|
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
