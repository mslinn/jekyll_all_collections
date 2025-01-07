# Ruby's binary search is unsuitable because the value to be searched for changes the required ordering for String compares
class MSlinnBinarySearch
  attr_reader :array

  def initialize(accessor_chain)
    @array = [] # Ordered highest to lowest
    @accessor_chain = accessor_chain
  end

  # TODO: Cache this method
  def suffix_binary_search(suffix)
    chain = @accessor_chain + [suffix]
    low = @array.bsearch_index { |x| x.send_chain_with_values suffix }
    return [] if low.nil?

    high = low
    high += 1 while high < @array.length &&
                    @array[high].send_chain_with_values(suffix)
    @array[low..high]
  end

  def binary_insert(url, new_item)
    chain = @accessor_chain + [url]
    new_value = new_item.send_chain(chain)
    insert_at = @array.bsearch_index { |x| x.send_chain chain, new_value }
    insert_at ||= 0
    @array.insert(insert_at, new_item)
  end

  # @return index of matching val
  def binary_search_index(target)
    _binary_search(target, 0, @array.length)
  end

  private

  def _binary_search(target, min_index, max_index)
    mid_index = (min_index + max_index) / 2
    item = @array[mid_index]
    len = [item.length, target.length].min
    case item[len] <=> target[len]
    when 0 # array[mid_index] == target
      mid_index
    when -1  # array[mid_index] < target
      min_index = mid_index + 1
      _binary_search(target, min_index, max_index)
    when  1  # array[mid_index] > target
      max_index = mid_index - 1
      _binary_search(target, min_index, max_index)
    end
  end
end
