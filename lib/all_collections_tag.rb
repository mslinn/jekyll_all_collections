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

      sort_by = @helper.parameter_specified?('sort_by') || 'date'
      sort_lambda = self.class.create_lambda sort_by
      generate_output(sort_lambda) # Descending sorts are reversed here
    end

    def self.create_lambda(criteria)
      criteria_array = []
      verify_sort_by_type(criteria).each do |c|
        @sign = c.start_with?('-') ? '-' : ''
        c.delete_prefix! '-'
        abort("Error: '#{c}' is not a valid sort field. Valid field names are: #{CRITERIA.join(', ')}") unless CRITERIA.include?(c)
        criteria_array << "#{@sign}a.#{c}"
      end
      # Examples:
      #   "->(a) { [a.date] }"
      #   "->(a) { [-a.date, a.last_modified] }"
      lambda_string = "->(a) { [#{criteria_array.join(', ')}] }"
      eval lambda_string
    end

    def self.sort_me(collection, sort_lambda)
      collection.sort_by(&sort_lambda)
    end

    def self.verify_sort_by_type(sort_by)
      if @sort_by.is_a? Array
        sort_by
      elsif sort_by.is_a? Enumerable
        sort_by.to_a
      elsif sort_by.is_a? Date
        [sort_by.to_i]
      elsif sort_by.is_a? String
        [sort_by]
      else
        abort "Error: sort_by was specified as '#{sort_by}'; it must either be a string or an array of strings"
      end
    end

    private

    def generate_output(sort_lambda)
      collection = self.class.sort_me(@site.all_collections, sort_lambda)
      <<~END_TEXT
        <h2 id="posts">Posts Sorted By Age</h2>
        <div class="posts">
        #{(collection.map do |post|
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
