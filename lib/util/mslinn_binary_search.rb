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
  # @param suffix [String] to use stem search on
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

  # @param value [String]
  # @return item from array that matches value, or nil if no match
  def find(value)
    raise MSlinnBinarySearchError, 'Invalid find because value to search for is nil.' if value.nil?

    return nil if @array.empty?

    index = _find_index(value, 0, @array.length)
    return nil if index.nil?

    @array[index]
  end

  # @param value [String]
  # @return index of matching value, or nil if @array is empty
  def find_index(value)
    raise MSlinnBinarySearchError, 'Invalid find_index because value to search for is nil.' if value.nil?
    return nil if @array.empty?
    return 0 if value.nil? || value.empty?

    _find_index(value, 0, @array.length - 1)
  end

  # @param lru_file [LruFile]
  def insert(lru_file)
    raise MSlinnBinarySearchError, 'Invalid insert because new item is nil.' if lru_file.nil?
    raise MSlinnBinarySearchError, "Invalid insert because new item has no chain (#{lru_file})" if lru_file.chain.nil?

    insert_at = find_index(lru_file.url) # TODO: replace .url with chain eval
    insert_at = insert_at.nil? ? 0 : insert_at + 1
    @array.insert(insert_at, lru_file)
  end

  # @param item [String]
  # @return [int] index of matching item in @array, or nil if not found
  def index_of(item)
    raise MSlinnBinarySearchError, 'Invalid index_of item (nil).' if item.nil?

    find_index item.url
  end

  # @return [LruFile] item at given index in @array
  def item_at(index)
    if index >= @array.length - 1
      raise MSlinnBinarySearchError,
            "Invalid item_at index (#{index}) is greater than maximum value (#{@array.length - 1})."
    end
    raise MSlinnBinarySearchError, "Invalid item_at index (#{index}) is less than zero." if index.negative?

    @array[index]
  end

  private

  # @param target [String]
  # @return [int] index of matching item in @array
  def _find_index(target, min_index, max_index)
    mid_index = (min_index + max_index) / 2
    mid_item = @array[mid_index]
    len = [mid_item.url.length, target.length].min # TODO: use chain eval for item
    case mid_item.url[len] <=> target[len] # TODO: use chain eval for item
    when 0 # mid_item.url[len] == target[len]
      mid_index
    when -1  # mid_item.url[len] > target[len]
      min_index = mid_index + 1
      _find(target, min_index, max_index)
    when  1  # mid_item.url[len] > target[len]
      max_index = mid_index - 1
      _find(target, min_index, max_index)
    end
  end
end
