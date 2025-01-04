module AllCollectionsHooks
  @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)

  # No, all_collections is not defined for this hook
  # Jekyll::Hooks.register(:site, :after_init, priority: :normal) do |site|
  #   defined = AllCollectionsHooks.all_collections_defined?(site)
  #   @logger.debug { "Jekyll::Hooks.register(:site, :after_init: #{defined}" }
  # end

  # Creates a `Array[APage]` property called site.all_collections if it does not already exist.
  # The array is available from :site, :pre_render onwards
  # Each `APage` entry is one document or page.
  Jekyll::Hooks.register(:site, :post_read, priority: :normal) do |site|
    @site = site
    defined = AllCollectionsHooks.all_collections_defined? site
    @logger.debug { "Jekyll::Hooks.register(:site, :post_read, :normal: #{defined}" }
    AllCollectionsHooks.compute(site) unless site.class.method_defined? :all_collections
  rescue StandardError => e
    JekyllSupport.error_short_trace(@logger, e)
    # JekyllSupport.warn_short_trace(@logger, e)
  end

  # Yes, all_collections is defined for this hook
  # Jekyll::Hooks.register(:site, :post_read, priority: :low) do |site|
  #   defined = AllCollectionsHooks.all_collections_defined?(site)
  #   @logger.debug { "Jekyll::Hooks.register(:site, :post_read, :low: #{defined}" }
  # rescue StandardError => e
  #   JekyllSupport.error_short_trace(@logger, e)
  #   # JekyllSupport.warn_short_trace(@logger, e)
  # end

  # Yes, all_collections is defined for this hook
  # Jekyll::Hooks.register(:site, :post_read, priority: :normal) do |site|
  #   defined = AllCollectionsHooks.all_collections_defined?(site)
  #   @logger.debug { "Jekyll::Hooks.register(:site, :post_read, :normal: #{defined}" }
  # rescue StandardError => e
  #   JekyllSupport.error_short_trace(@logger, e)
  #   # JekyllSupport.warn_short_trace(@logger, e)
  # end

  # Yes, all_collections is defined for this hook
  # Jekyll::Hooks.register(:site, :pre_render, priority: :normal) do |site, _payload|
  #   defined = AllCollectionsHooks.all_collections_defined?(site)
  #   @logger.debug { "Jekyll::Hooks.register(:site, :pre_render: #{defined}" }
  # rescue StandardError => e
  #   JekyllSupport.error_short_trace(@logger, e)
  #   # JekyllSupport.warn_short_trace(@logger, e)
  # end
end

PluginMetaLogger.instance.logger.info do
  "Loaded AllCollectionsHooks v#{JekyllAllCollectionsVersion::VERSION} :site, :pre_render, :normal hook plugin."
end
Liquid::Template.register_filter(AllCollectionsHooks)
