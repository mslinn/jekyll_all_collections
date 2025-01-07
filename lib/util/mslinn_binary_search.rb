# Ruby's binary search is unsuitable because the value to be searched for changes the required ordering for String compares
class MSlinnBinarySearch
  attr_reader :array # For testing only

  def initialize(accessor_chain)
    @array = [] # Ordered highest to lowest
    @accessor_chain = accessor_chain
  end

  # TODO: Cache this method
  def suffix_search(suffix)
    low = search_index { |x| x.evaluate_with suffix }
    return [] if low.nil?

    high = low
    high += 1 while high < @array.length &&
                    @array[high].evaluate_with(suffix)
    @array[low..high]
  end

  # @return item from array that matches value
  def find(value)
    index = _find_index(value, 0, @array.length)
    @array[index]
  end

  # @return index of matching value
  def find_index(value)
    _find_index(value, 0, @array.length)
  end

  def insert(lru_file)
    insert_at = search_index(lru_file) { |x| x.evaluate_with lru_file.url }
    insert_at ||= 0
    @array.insert(insert_at, new_item)
  end

  def item_at(index)
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
