require_relative '../util/mslinn_binary_search'

# Insert the reversed url of a Jekyll::Page into each LruFile instance,
# along with the Page reference
LruFile = Struct.new(:reversed_url, :page)

class SortedLruFiles
  def initialize
    @sorted_lru_files = MSlinnBinarySearch.new
  end

  def add_pages(pages)
    pages.each { |page| insert page.url, page }
  end

  def insert(url, file)
    @sorted_lru_files.binary_insert(LruFile.new(url.reverse, file))
  end

  def select(prefix)
    @sorted_lru_files.prefix_binary_search prefix
  end
end
