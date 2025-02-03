require_relative '../util/send_chain'

# Insert the url of a Jekyll::Page into each LruFile instance,
# along with the Page reference
# todo: replace references to url and :url with reverse_url and :reverse_url
LruFile = Struct.new(:url, :page) do
  include SendChain
end

# Matches suffixes of an array of urls
# Converts suffixes to prefixes
class SortedLruFiles
  attr_reader :msbs

  def initialize
    @msbs = MSlinnBinarySearch.new %i[url start_with?]
  end

  def add_pages(pages) # TODO: test this
    pages.each { |page| insert page.href, page }
  end

  def insert(url, file) # TODO: test this
    lru_file = LruFile.new(url, file)
    lru_file.new_chain [:url, %i[start_with? placeholder]]
    @msbs.insert(lru_file)
  end

  def select(suffix) # TODO: test this
    @msbs.select_pages suffix
  end
end
