require 'jekyll_draft'
require 'jekyll_plugin_logger'
require 'jekyll_plugin_support'
require 'securerandom'

# See https://stackoverflow.com/a/75389679/553865
class NullBinding < BasicObject
  def min_binding
    ::Kernel
      .instance_method(:binding)
      .bind(self)
      .call
  end
end

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

      @id = @helper.parameter_specified?('id') || SecureRandom.hex(10)
      sort_by = (
        value = @helper.parameter_specified?('sort_by')
        value&.gsub(' ', '')&.split(',') if value != false
      ) || '-date'
      @heading = @helper.parameter_specified?('heading') || "All Posts Sorted By #{sort_by.capitalize}"
      sort_lambda_string = self.class.create_lambda_string(sort_by)
      sort_lambda = self.class.evaluate(sort_lambda_string)
      generate_output(sort_lambda)
    end

    # Descending sort keys reverse the order of comparison
    def self.create_lambda_string(criteria)
      criteria_lhs_array = []
      criteria_rhs_array = []
      verify_sort_by_type(criteria).each do |c|
        descending_sort = c.start_with?('-')
        c.delete_prefix! '-'
        abort("Error: '#{c}' is not a valid sort field. Valid field names are: #{CRITERIA.join(', ')}") \
          unless CRITERIA.include?(c)
        criteria_lhs_array << (descending_sort ? "b.#{c}" : "a.#{c}")
        criteria_rhs_array << (descending_sort ? "a.#{c}" : "b.#{c}")
      end
      # Examples:
      #   "->(a, b) { [a.last_modified] <=> [b.last_modified] }"
      #   "->(a, b) { [b.last_modified] <=> [a.last_modified] }" (descending)
      #   "->(a, b) { [a.last_modified, a.date] <=> [b.last_modified, b.date] }" (descending last_modified, ascending date)
      #   "->(a, b) { [a.last_modified, b.date] <=> [b.last_modified, a.date] }" (ascending last_modified, descending date)
      "->(a, b) { [#{criteria_lhs_array.join(', ')}] <=> [#{criteria_rhs_array.join(', ')}] }"
    end

    def self.evaluate(string)
      eval string, NullBinding.new.min_binding, __FILE__, __LINE__ # rubocop:disable Security/Eval
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
      id = @id.to_s.empty? ? '' : " id='#{@id}'"
      heading = @heading.to_s.empty? ? '' : "<h2#{id}>#{@heading}</h2>"
      collection = @site.all_collections.sort(&sort_lambda)
      <<~END_TEXT
        #{heading}
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
