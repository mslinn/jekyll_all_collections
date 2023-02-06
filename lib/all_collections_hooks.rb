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

  # Creates a `Array[String]` property called site.all_collections if it does not already exist
  # Each `APage` entry is one document or page.
  Jekyll::Hooks.register(:site, :post_read, priority: :normal) do |site|
    defined = AllCollectionsHooks.all_collections_defined?(site)
    @logger.info { "Jekyll::Hooks.register(:site, :post_read, :normal: #{defined}" }
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

  # The collection value is just the collection label, not the entire collection object
  def self.apages_from_objects(objects)
    pages = []
    objects.each do |object|
      pages << APage.new(object)
    end
    pages
  end

  def self.all_collections_defined?(site)
    "site.all_collections #{site.class.method_defined?(:all_collections) ? 'IS' : 'IS NOT'} defined"
  end

  class APage
    attr_reader :content, :data, :destination, :draft, :label, :path, :relative_path, :title, :type, :url

    def initialize(obj) # rubocop:disable Metrics/AbcSize
      @content = obj.content
      @data = obj.data
      @destination = obj.destination('') # TODO: What _config.yml setting should be passed to destination()?
      @categories = @data['categories']
      @date = @data['date']
      @description = @data['description']
      @excerpt = @data['excerpt']
      @ext = @data['ext']
      @label = obj.collection.label
      @last_modified = @data['last_modified']
      @layout = @data['layout']
      @path = obj.path
      @tags = @data['tags']
      @title = @data['title']
      @type = obj.type
      @url = obj.url
    end
  end

  PluginMetaLogger.instance.logger.info {
    "Loaded AllCollectionsHooks v#{JekyllAllCollectionsVersion::VERSION} :site, :pre_render, :normal hook plugin."
  }
end

Liquid::Template.register_filter(AllCollectionsHooks)
