module SendChain
  def new_chain(chain)
    abort "new_chain error: chain must be an array ('#{chain}' was an #{chain.class.name})" unless chain.instance_of?(Array)
    @chain = chain
  end

  # Call this method if one or more methods in the chain require arguments
  # Provide a :placeholder inside an inner array for every argument
  def send_chain_with_values(values)
    @values = values.instance_of?(Array) ? values : [values]

    placeholder_count = @chain.flatten.count { |x| x == :placeholder }
    if @values.length != placeholder_count
      abort "with_values error: number of values (#{@values.length}) does not match the number of placeholders (#{placeholder_count})"
    end

    substituted_chain = eval_chain @chain
    send_chain substituted_chain
  end

  # See https://stackoverflow.com/a/35754367/553865
  # This method can be called directly if no methods in the chain require arguments
  def send_chain(chain)
    Array(chain).inject(self) { |o, a| o.send(*a) }
  end

  def eval_chain(chain)
    chain.map do |c|
      case c
      when :placeholder
        @values.pop
      when Array
        eval_chain c
      else
        c
      end
    end
  end
end
