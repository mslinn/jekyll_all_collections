require 'jekyll_draft'
require 'jekyll_plugin_logger'
require 'jekyll_plugin_support'

# @author Copyright 2020 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0
module AllCollectionsTag
  PLUGIN_NAME = 'all_collections'.freeze
  CRITERIA = %w[date destination draft label last_modified path relative_path title type url].freeze

  class AllCollectionsTag < JekyllSupport::JekyllTag
    # Method prescribed by JekyllTag.
    # @return [String]
    def render_impl
      AllCollectionsHooks.compute(@site) unless @site.class.method_defined? :all_collections

      sort_by = @helper.parameter_specified?('sort_by') || 'date:asc'
      sort_lambda = create_lambda(verify_sort_by_type(sort_by))
      generate_output(sort_lambda)
    end

    private

    def create_lambda(criteria)
      criteria.each do |c|
        lambda(&:date)
      end
    end

    def generate_output(sort_lambda)
      <<~END_TEXT
        <h2 id="posts">Posts Sorted By Age</h2>
        <div class="posts">
        #{(@site.all_collections.sort(sort_lambda).map do |post|
             draft = Jekyll::Draft.draft_html post
             date = post.data['date'].strftime('%Y-%m-%d')
             href = "<a href='#{post.url}'>#{post.title}</a>"
             "  <span>#{date}</span><span>#{href}#{draft}</span>"
           end).join("\n")}
        </div>
      END_TEXT
    end

    def verify_sort_by_type(sort_by)
      if @sort_by.is_a? Array
        sort_by
      elsif sort_by.is_a? Enumerable
        sort_by.to_a
      elsif sort_by.is_a? String
        [sort_by]
      else
        abort "Error: sort_by was specified as '#{sort_by}'; it must either be a string or an array of strings"
      end
    end
  end
end

Liquid::Template.register_tag(AllCollectionsTag::PLUGIN_NAME, AllCollectionsTag::AllCollectionsTag)
PluginMetaLogger.instance.info { "Loaded #{AllCollectionsTag::PLUGIN_NAME} v#{JekyllAllCollectionsVersion::VERSION} tag plugin." }
