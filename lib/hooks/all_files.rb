# Insert the reversed url of a Jekyll::Page into each LruPage instance
LruPage = Struct.new(:reversed_url, :page)

class SortedFiles
  @sorted_lru_pages = []

  # Example usage:
  # prefix_binary_search('bb').map(&:url).map(&:reverse)
  # Yields: ["bbb", "bbbba", "bbc", "bbd", "bbdefg"]
  # todo: Cache thi method
  def prefix_binary_search(prefix)
    low = 0
    high = @sorted_lru_pages.length - 1
    result = []

    # Binary search to find the first position where the prefix might match
    while low <= high
      mid = low + ((high - low) / 2)
      # Compare the prefix to the substring of the @sorted_lru_pages element
      if @sorted_lru_pages[mid].url < prefix
        low = mid + 1
      elsif @sorted_lru_pages[mid].url > prefix
        high = mid - 1
      end
    end

    # Collect all matching elements from 'low' onward
    while low < @sorted_lru_pages.length && @sorted_lru_pages[low].url.start_with?(prefix)
      result << @sorted_lru_pages[low]
      low += 1
    end

    result
  end

  def insert_in_sorted_order(item)
    insert_at = @sorted_lru_pages.bsearch_index { |x| x.url >= item.url }
    @sorted_lru_pages.insert(insert_at, item)
  end
end
