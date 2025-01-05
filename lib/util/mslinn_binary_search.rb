class MSlinnBinarySearch
  attr_reader :sorted_lru_files

  def initialize
    @sorted_lru_files = []
  end

  # Example usage:
  # prefix_binary_search('bb').map(&:url).map(&:reverse)
  # Yields: ["bbb", "bbbba", "bbc", "bbd", "bbdefg"]
  # todo Cache this method
  def prefix_binary_search(prefix)
    low = 0
    high = @sorted_lru_files.length - 1
    result = []

    # Binary search to find the first position where the prefix might match
    while low < high
      mid = low + ((high - low) / 2)
      # Compare the prefix to the substring of the @sorted_lru_files element
      if @sorted_lru_files[mid].reversed_url < prefix
        low = mid + 1
      elsif @sorted_lru_files[mid].reversed_url > prefix
        high = mid - 1
      end
    end

    # Collect all matching elements from 'low' onward
    while low < @sorted_lru_files.length && @sorted_lru_files[low].reversed_url.start_with?(prefix)
      result << @sorted_lru_files[low]
      low += 1
    end

    result
  end

  def binary_insert(item)
    insert_at = @sorted_lru_files.bsearch_index { |x| x.reversed_url >= item.reversed_url } || 0
    @sorted_lru_files.insert(insert_at, item)
  end
end
