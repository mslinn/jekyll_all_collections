module AllCollectionsHooks
  # @sort_by = ->(apages, criteria) { [apages.sort(criteria)] }

  def self.all_collections_defined?(site)
    "site.all_collections #{site.class.method_defined?(:all_collections) ? 'IS' : 'IS NOT'} defined"
  end

  # The collection value is just the collection label, not the entire collection object
  def self.apages_from_objects(objects, origin)
    pages = []
    objects.each do |object|
      page = APage.new(object, origin)
      pages << page unless page.data['exclude_from_all']
    end
    pages
  end

  def self.compute(site)
    site.class.module_eval { attr_accessor :all_collections, :all_documents, :everything, :sorted_lru_files }

    objects = site.collections
                  .values
                  .map { |x| x.class.method_defined?(:docs) ? x.docs : x }
                  .flatten
    @all_collections  = AllCollectionsHooks.apages_from_objects(objects, 'collection')
    @all_documents    = @all_collections +
                        AllCollectionsHooks.apages_from_objects(site.pages, 'individual_page')
    @everything       = @all_documents +
                        AllCollectionsHooks.apages_from_objects(site.static_files, 'static_file')
    @sorted_lru_files = SortedLruFiles.new.add_pages @everything

    site.all_collections  = @all_collections
    site.all_documents    = @all_documents
    site.everything       = @everything
    site.sorted_lru_files = @sorted_lru_files
  rescue StandardError => e
    JekyllSupport.error_short_trace(AllCollectionsHooks.logger, e)
    # JekyllSupport.warn_short_trace(AllCollectionsHooks.logger, e)
  end
end
