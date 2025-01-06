class MSlinnBinarySearch
  attr_reader :array

  def initialize(accessor_method)
    @array = []
    @accessor_method = accessor_method
  end

  # Matches from the end of an array of strings
  # todo Cache this method
  def suffix_binary_search(suffix)
    low = 0
    high = @array.length - 1
    result = []

    # Binary search to find the first position where the suffix might match
    while low < high
      mid = low + ((high - low) / 2)
      # Compare the suffix to the substring of the @array element
      element = @array[mid]
      if element.send(@accessor_method) > suffix
        high = mid - 1
      elsif element.send(@accessor_method) <= suffix
        low = mid + 1
      end
    end

    # Collect all matching elements from 'low' onward
    while low < @array.length &&
          @array[low].send(@accessor_method).end_with?(suffix)
      result << @array[low]
      low += 1
    end

    result
  end

  def binary_insert(new_item)
    new_value = new_item.send(@accessor_method)
    insert_at = @array.bsearch_index { |x| x.send(@accessor_method) >= new_value }
    insert_at ||= @array.length
    @array.insert(insert_at, new_item)
  end
end
