require_relative '../util/mslinn_binary_search'

# Insert the url of a Jekyll::Page into each LruFile instance,
# along with the Page reference
LruFile = Struct.new(:url, :page) do
  # See https://stackoverflow.com/a/35754367/553865
  def send_chain(arr)
    Array(arr).inject(self) { |o, a| o.send(*a) }
  end
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
    @msbs.binary_insert(url, LruFile.new(url, file))
  end

  def select(suffix)
    @msbs.suffix_binary_search suffix
  end
end
