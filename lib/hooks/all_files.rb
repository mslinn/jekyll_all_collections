require_relative '../util/mslinn_binary_search'

# Insert the url of a Jekyll::Page into each LruFile instance,
# along with the Page reference
LruFile = Struct.new(:url, :page) do
  include SendChain
end

# Matches suffixes of an array of urls
class SortedLruFiles
  attr_reader :msbs

  def initialize
    @msbs = MSlinnBinarySearch.new %i[url end_with?]
  end

  def add_pages(pages)
    pages.each { |page| insert page.url, page }
  end

  def insert(url, file)
    lru_file = LruFile.new(url, file)
    lru_file.new_chain [:url, %i[start_with? placeholder]]
    @msbs.binary_insert(url, lru_file)
  end

  def select(suffix)
    @msbs.suffix_binary_search suffix
  end
end
