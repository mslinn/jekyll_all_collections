require_relative '../util/mslinn_binary_search'

# Insert the reversed url of a Jekyll::Page into each LruFile instance,
# along with the Page reference
LruFile = Struct.new(:url, :page)

class SortedLruFiles
  attr_reader :msbs

  def initialize
    @msbs = MSlinnBinarySearch.new :url
  end

  def add_pages(pages)
    pages.each { |page| insert page.url, page }
  end

  def insert(url, file)
    @msbs.binary_insert(LruFile.new(url, file))
  end

  def select(suffix)
    @msbs.suffix_binary_search suffix
  end
end
