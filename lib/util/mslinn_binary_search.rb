class MSlinnBinarySearch
  attr_reader :array

  def initialize(accessor_chain)
    @array = [] # Ordered highest to lowest
    @accessor_chain = accessor_chain
  end

  # TODO: Cache this method
  def suffix_binary_search(suffix)
    chain = @accessor_chain + [suffix]
    low = @array.bsearch_index { |x| x.send_chain(chain) }
    return [] if low.nil?

    high = low
    high += 1 while high < @array.length &&
                    @array[high].send_chain(chain)
    @array[low..high]
  end

  def binary_insert(url, new_item)
    chain = @accessor_chain + [url]
    new_value = new_item.send_chain(chain)
    insert_at = @array.bsearch_index { |x| x.send_chain chain, new_value }
    insert_at ||= 0
    @array.insert(insert_at, new_item)
  end
end
