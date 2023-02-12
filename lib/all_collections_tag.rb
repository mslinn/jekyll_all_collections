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
  CRITERIA = %w[date destination draft label last_modified last_modified_at path relative_path title type url].freeze

  class AllCollectionsTag < JekyllSupport::JekyllTag
    # Method prescribed by JekyllTag.
    # @return [String]
    def render_impl
      AllCollectionsHooks.compute(@site) unless @site.class.method_defined? :all_collections

      @date_column = @helper.parameter_specified?('date_column') || 'date'
      abort "Error: the date_column attribute must either have value 'date' or 'last_modified', but '#{@date_column}' was specified" \
        unless %w[date last_modified].include?(@date_column)

      @id = @helper.parameter_specified?('id') || SecureRandom.hex(10)
      sort_by_param = @helper.parameter_specified?('sort_by')
      sort_by = (sort_by_param&.gsub(' ', '')&.split(',') if sort_by_param != false) || ['-date']
      @heading = @helper.parameter_specified?('heading') || self.class.default_head(sort_by)
      sort_lambda_string = self.class.create_lambda_string(sort_by)
      @logger.debug "#{@page['path']} sort_by_param=#{sort_by_param}"
      @logger.debug "  sort_lambda_string = #{sort_lambda_string}\n"
      sort_lambda = self.class.evaluate(sort_lambda_string)
      generate_output(sort_lambda)
    end

    def self.default_head(sort_by)
      criteria = (sort_by.map do |x|
        reverse = x.start_with? '-'
        criterion = x.delete_prefix('-').capitalize
        criterion += reverse ? ' (Newest to Oldest)' : ' (Oldest to Newest)'
        criterion
      end).join(', ')
      "All Posts in All Categories Sorted By #{criteria}"
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
      @site.all_collections.each do |post|
        # @logger.debug "#{post.relative_path}: last_modified=#{post.last_modified}(#{post.last_modified.class}) date=#{post.date}(#{post.date.class})"
        @logger.debug "Error: #{post.relative_path} has no value for last_modified" if post.last_modified.to_s.empty?
      end
      collection = @site.all_collections.sort(&sort_lambda)
      <<~END_TEXT
        #{heading}
        <div class="posts">
        #{(collection.map do |post|
             @logger.debug { "  post.last_modified='#{post.last_modified}' @date_column='#{@date_column}'" }
             date = (@date_column == 'last_modified' ? post.last_modified : post.date).strftime('%Y-%m-%d')
             draft = post.draft ? "<i class='jekyll_draft'>Draft</i>" : ''
             href = "<a href='#{post.url}'>#{post.title}</a>"
             @logger.debug { "  date='#{date}' #{post.title}\n" }
             "  <span>#{date}</span><span>#{href}#{draft}</span>"
           end).join("\n")}
        </div>
      END_TEXT
    rescue ArgumentError => e
      puts e.message
      puts e.backtrace.join("\n")
    end
  end
end

Liquid::Template.register_tag(AllCollectionsTag::PLUGIN_NAME, AllCollectionsTag::AllCollectionsTag)
PluginMetaLogger.instance.info { "Loaded #{AllCollectionsTag::PLUGIN_NAME} v#{JekyllAllCollectionsVersion::VERSION} tag plugin." }
