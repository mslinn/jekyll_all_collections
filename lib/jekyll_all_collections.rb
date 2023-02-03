# frozen_string_literal: true

require "jekyll"
require "jekyll_plugin_logger"
require_relative "jekyll_all_collections/version"

# Creates a hashmap called site.all_collections
module JekyllAllCollections
  @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)

  # Creates a hashmap[String, String|Array[String]] called site.all_collections if it does not already exist
  # Each hashmap entry is one document.
  # Returns hashmap
  def maybe_compute_all_collections(site)
    @logger.debug { "JekyllAllCollections.maybe_compute_all_collections invoked" }
    return site.all_collections if site.class.method_defined? :all_collections

    @logger.debug { "JekyllAllCollections.maybe_compute_all_collections creating site.all_collections" }

    objects = site.collections
                  .values
                  .map { |x| x.class.method_defined?(:docs) ? x.docs : x }
                  .flatten

    site.class.module_eval { attr_accessor :all_collections }
    site.all_collections = JekyllAllCollections.hashes_from_objects(objects)
    site.all_collections
  end

  # The collection value is just the collection label, not the entire collection object
  def self.hash_from_object(obj)
    hash = {}
    %w[collection content data destination path relative_path type url].each do |name_stub|
      name_symbol = "@#{name_stub}".to_sym
      value = obj.instance_variable_get(name_symbol)
      hash[name_stub] = value
    end
    hash['collection'] = hash['collection'].label
    hash
  end

  def self.hashes_from_objects(objects)
    array = []
    objects.each do |object|
      array << JekyllAllCollections.hash_from_object(object)
    end
    array
  end

  module_function :maybe_compute_all_collections

  PluginMetaLogger.instance.logger.info { "Loaded JekyllAllCollections v#{JekyllAllCollectionsVersion::VERSION} plugin." }
end
