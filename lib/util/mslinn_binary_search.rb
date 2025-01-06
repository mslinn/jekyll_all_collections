class MSlinnBinarySearch
  attr_reader :sorted_lru_files

  def initialize(accessor_method)
    @sorted_lru_files = []
    @accessor_method = accessor_method
  end

  # Matches from the end of an array of strings
  # todo Cache this method
  def prefix_binary_search(prefix)
    prefix = prefix.reverse
    low = 0
    high = @sorted_lru_files.length - 1
    result = []

    # Binary search to find the first position where the prefix might match
    while low < high
      mid = low + ((high - low) / 2)
      # Compare the prefix to the substring of the @sorted_lru_files element
      element = @sorted_lru_files[mid]
      if element.send(@accessor_method) < prefix
        low = mid + 1
      elsif element.send(@accessor_method) > prefix
        high = mid - 1
      end
    end

    # Collect all matching elements from 'low' onward
    while low < @sorted_lru_files.length && @sorted_lru_files[low].send(@accessor_method).start_with?(prefix)
      result << @sorted_lru_files[low]
      low += 1
    end

    result
  end

  def binary_insert(item)
    insert_at = @sorted_lru_files.bsearch_index { |x| x.send(@accessor_method) >= item.send(@accessor_method) } || 0
    @sorted_lru_files.insert(insert_at, item)
  end
end
