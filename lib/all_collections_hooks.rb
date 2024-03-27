require 'jekyll'
require 'jekyll_plugin_logger'
require_relative 'jekyll_all_collections/version'

# Creates an array of `APage` called site.all_collections, which will be available from :site, :pre_render onwards
module AllCollectionsHooks
  @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)

  # No, all_collections is not defined for this hook
  # Jekyll::Hooks.register(:site, :after_init, priority: :normal) do |site|
  #   defined = AllCollectionsHooks.all_collections_defined?(site)
  #   @logger.debug { "Jekyll::Hooks.register(:site, :after_init: #{defined}" }
  # end

  # Creates a `Array[APage]` property called site.all_collections if it does not already exist
  # Each `APage` entry is one document or page.
  Jekyll::Hooks.register(:site, :post_read, priority: :normal) do |site|
    defined = AllCollectionsHooks.all_collections_defined?(site)
    @logger.debug { "Jekyll::Hooks.register(:site, :post_read, :normal: #{defined}" }
    AllCollectionsHooks.compute(site) unless site.class.method_defined? :all_collections
  end

  # Yes, all_collections is defined for this hook
  # Jekyll::Hooks.register(:site, :post_read, priority: :low) do |site|
  #   defined = AllCollectionsHooks.all_collections_defined?(site)
  #   @logger.debug { "Jekyll::Hooks.register(:site, :post_read, :low: #{defined}" }
  # end

  # Yes, all_collections is defined for this hook
  # Jekyll::Hooks.register(:site, :post_read, priority: :normal) do |site|
  #   defined = AllCollectionsHooks.all_collections_defined?(site)
  #   @logger.debug { "Jekyll::Hooks.register(:site, :post_read, :normal: #{defined}" }
  # end

  # Yes, all_collections is defined for this hook
  # Jekyll::Hooks.register(:site, :pre_render, priority: :normal) do |site, _payload|
  #   defined = AllCollectionsHooks.all_collections_defined?(site)
  #   @logger.debug { "Jekyll::Hooks.register(:site, :pre_render: #{defined}" }
  # end

  def self.compute(site)
    objects = site.collections
                  .values
                  .map { |x| x.class.method_defined?(:docs) ? x.docs : x }
                  .flatten

    site.class.module_eval { attr_accessor :all_collections }
    apages = AllCollectionsHooks.apages_from_objects(objects)
    site.all_collections = apages
  end

  @sort_by = ->(apages, criteria) { [apages.sort(criteria)] }

  # The collection value is just the collection label, not the entire collection object
  def self.apages_from_objects(objects)
    pages = []
    objects.each do |object|
      page = APage.new(object)
      pages << page unless page.data['exclude_from_all']
    end
    pages
  end

  def self.all_collections_defined?(site)
    "site.all_collections #{site.class.method_defined?(:all_collections) ? 'IS' : 'IS NOT'} defined"
  end

  class APage
    attr_reader :content, :data, :date, :description, :destination, :draft, :excerpt, :ext, :extname,
                :label, :last_modified, :layout, :path, :relative_path, :tags, :title, :type, :url

    # Verify each property exists before accessing it; this helps write tests
    def initialize(obj) # rubocop:disable Metrics/AbcSize
      @data = obj.data if obj.respond_to? :data

      @categories = @data['categories'] if @data.key? 'categories'
      @content = obj.content if obj.respond_to? :content
      @date = (@data['date'].to_date if @data&.key?('date')) || Date.today
      @description = @data['description'] if @data.key? 'description'

      # TODO: What _config.yml setting should be passed to destination()?
      @destination = obj.destination('') if obj.respond_to? :destination

      @draft = Jekyll::Draft.draft?(obj)
      @excerpt = @data['excerpt'] if @data.key? 'excerpt'
      @ext = obj.extname
      @ext ||= @data['ext'] if @data.key? 'ext'
      @extname = @ext # For compatibility with previous versions of all_collections
      @label = obj.collection.label if obj&.collection.respond_to? :label
      @last_modified = @data['last_modified'] || @data['last_modified_at'] || @date
      @last_modified_field = case @data
                             when @data.key?('last_modified')
                               'last_modified'
                             when @data.key?('last_modified_at')
                               'last_modified_at'
                             end
      @layout = @data['layout'] if @data.key? 'layout'
      @path = obj.path if obj.respond_to? :path
      @relative_path = obj.relative_path if obj.respond_to? :relative_path
      @tags = @data['tags'] if @data.key? 'tags'
      @title = @data['title'] if @data.key? 'title'
      @type = obj.type if obj.respond_to? :type
      @url = obj.url
    end

    def to_s
      return @label if @label

      @date.to_s
    end
  end

  PluginMetaLogger.instance.logger.info do
    "Loaded AllCollectionsHooks v#{JekyllAllCollectionsVersion::VERSION} :site, :pre_render, :normal hook plugin."
  end
end

Liquid::Template.register_filter(AllCollectionsHooks)
