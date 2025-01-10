unless defined?(MSlinnBinarySearchError)
  class MSlinnBinarySearchError < StandardError
  end
end

# Ruby's binary search is unsuitable because the value to be searched for changes the required ordering for String compares
class MSlinnBinarySearch
  attr_reader :array # For testing only

  def initialize(accessor_chain)
    @array = [] # [LruFile] Ordered highest to lowest
    @accessor_chain = accessor_chain
  end

  # @param value [String]
  # @return item from array that matches value, or nil if no match
  def find(value)
    raise MSlinnBinarySearchError, 'Invalid find because value to search for is nil.' if value.nil?
    return nil if @array.empty?
    return @array[0] if value.nil? || value.empty?

    index = _find_index(value, 0, @array.length - 1)
    return nil if index.nil?

    @array[index]
  end

  # @param value [String]
  # @return index of first matching value, or nil if @array is empty, or 0 if no value specified
  def find_index(value)
    raise MSlinnBinarySearchError, 'Invalid find_index because value to search for is nil.' if value.nil?
    return nil if @array.empty?
    return 0 if value.nil? || value.empty?

    _find_index(value, 0, @array.length - 1)
  end

  # @param value [String]
  # @return [index] of matching values, or [] if @array is empty, or entire array if no value specified
  def find_indices(value)
    raise MSlinnBinarySearchError, 'Invalid find_indices because value to search for is nil.' if value.nil?
    return [] if @array.empty?
    return @array if value.nil? || value.empty?

    first_index = _find_index(value, 0, @array.length - 1)
    last_index = first_index
    last_index += 1 while @array[last_index].url.start_with? value
    [first_index..last_index]
  end

  # @param item [LruFile]
  # @return [int] index of matching LruFile in @array, or nil if not found
  def index_of(lru_file)
    raise MSlinnBinarySearchError, 'Invalid index_of lru_file (nil).' if lru_file.nil?

    find_index lru_file.url
  end

  # @return [LruFile] item at given index in @array
  def item_at(index)
    if index > @array.length - 1
      raise MSlinnBinarySearchError,
            "Invalid item_at index (#{index}) is greater than maximum value (#{@array.length - 1})."
    end
    raise MSlinnBinarySearchError, "Invalid item_at index (#{index}) is less than zero." if index.negative?

    @array[index]
  end

  # @param lru_file [LruFile]
  def insert(lru_file)
    raise MSlinnBinarySearchError, 'Invalid insert because new item is nil.' if lru_file.nil?
    raise MSlinnBinarySearchError, "Invalid insert because new item has no chain (#{lru_file})" if lru_file.chain.nil?

    insert_at = find_index(lru_file.url) # TODO: replace .url with chain eval
    insert_at ||= 0
    @array.insert(insert_at, lru_file)
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
  # @return [APage] matching APages, or [] if @array is empty, or entire array if no value specified
  def select_pages(value)
    first_index = find_index(value)
    last_index = first_index
    last_index += 1 while @array[last_index].url.start_with? value
    [first_index..last_index].map { |i| @array[i].page }
  end

  private

  # @param target [String]
  # @return [int] index of matching item in @array
  def _find_index(target, min_index, max_index)
    raise MSlinnBinarySearchError, 'min_index<0' if min_index.negative?
    raise MSlinnBinarySearchError, 'max_index>=@array.length' if max_index >= @array.length

    return nil if @array.empty?
    return 0 if @array[0].url >= target # TODO: use chain eval for item

    if min_index == max_index
      case @array[min_index].url <=> target # TODO: use chain eval for item
      when -1
        return [min_index + 1, 0].max
      when 0
        return min_index
      else
        return min_index - 1
      end
    end

    mid_index = (min_index + max_index) / 2
    mid_item = @array[mid_index] # [LruFile]
    len = [mid_item.url.length, target.length].min # TODO: use chain eval for item
    case mid_item.url[0..len - 1] <=> target[0..len - 1] # TODO: use chain eval for item
    when 0 # mid_item.url[0..len-1] == target[0..len-1]
      # puts "min_index=#{min_index} mid_index=#{mid_index} max_index=#{max_index} mid_item.url[0..#{len - 1}] (#{mid_item.url[0..len - 1]}) == target[0..#{len - 1}] (#{target[0..len - 1]})"
      mid_index
    when -1 # mid_item.url[len-1] < target[len-1]
      # puts "min_index=#{min_index} mid_index=#{mid_index} max_index=#{max_index} mid_item.url[0..#{len - 1}] (#{mid_item.url[0..len - 1]}) < target[0..#{len - 1}] (#{target[0..len - 1]})"
      min_index = mid_index + 1
      _find_index(target, min_index, max_index)
    when  1 # mid_item.url[len-1] > target[len-1]
      # puts "min_index=#{min_index} mid_index=#{mid_index} max_index=#{max_index} mid_item.url[0..#{len - 1}] (#{mid_item.url[0..len - 1]}) > target[0..#{len - 1}] (#{target[0..len - 1]})"
      max_index = mid_index - 1
      _find_index(target, min_index, max_index)
    end
  end
end
