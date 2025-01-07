unless defined?(MSlinnBinarySearchError)
  class MSlinnBinarySearchError < StandardError
  end
end

# Ruby's binary search is unsuitable because the value to be searched for changes the required ordering for String compares
class MSlinnBinarySearch
  attr_reader :array # For testing only

  def initialize(accessor_chain)
    @array = [] # Ordered highest to lowest
    @accessor_chain = accessor_chain
  end

  # TODO: Cache this method
  # @return nil if @array is empty
  # @return the first item in @array if suffix is nil or an empty string
  def prefix_search(suffix)
    return nil if @array.empty?
    return @array[0] if suffix.empty? || suffix.nil?

    low = search_index { |x| x.evaluate_with suffix }
    return [] if low.nil?

    high = low
    high += 1 while high < @array.length &&
                    @array[high].evaluate_with(suffix)
    @array[low..high]
  end

  # @return item from array that matches value, or nil if no match
  def find(value)
    raise MSlinnBinarySearchError, 'Invalid find because value to search for is nil.' if value.nil?

    return nil if @array.empty?

    index = _find_index(value, 0, @array.length)
    return nil if index.nil?

    @array[index]
  end

  # @return index of matching value, or nil if @array is empty
  def find_index(value)
    raise MSlinnBinarySearchError, 'Invalid find_index because value to search for is nil.' if value.nil?
    return nil if @array.empty?

    _find_index(value, 0, @array.length)
  end

  def insert(lru_file)
    raise MSlinnBinarySearchError, 'Invalid insert because new item is nil.' if lru_file.nil?
    raise MSlinnBinarySearchError, "Invalid insert because new item has no chain (#{lru_file})" if lru_file.chain.nil?

    insert_at = find_index(lru_file) { |x| x.evaluate_with lru_file.url }
    insert_at ||= 0
    @array.insert(insert_at, new_item)
  end

  # @return index of matching item in @array, or nil if not found
  def index_of(item)
    raise MSlinnBinarySearchError, 'Invalid index_of item (nil).' if item.nil?

    find_index item.url
  end

  # @return item at given index in @array
  def item_at(index)
    if index >= @array.length - 1
      raise MSlinnBinarySearchError,
            "Invalid item_at index (#{index}) is greater than maximum value (#{@array.length - 1})."
    end
    raise MSlinnBinarySearchError, "Invalid item_at index (#{index}) is less than zero." if index.negative?

    @array[index]
  end

  private

  def _find_index(target, min_index, max_index)
    mid_index = (min_index + max_index) / 2
    item = @array[mid_index]
    len = [item.length, target.length].min
    case item[len] <=> target[len]
    when 0 # array[mid_index] == target
      mid_index
    when -1  # array[mid_index] < target
      min_index = mid_index + 1
      _find(target, min_index, max_index)
    when  1  # array[mid_index] > target
      max_index = mid_index - 1
      _find(target, min_index, max_index)
    end
  end
end
