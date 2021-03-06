class Instruction
  attr_writer :expression_evaluator

  def initialize(parts)
    @parts_address = parts['ADDRESS']
    @parts_op = parts['OP']
    @parts_f = parts['F']
    @parts_i = parts['I']
    @expression_evaluator = nil
    @parsed_address = nil
  end

  def extract_address
    if @parts_address == nil
      return [Sign::POSITIVE, [0, 0]]
    end
    address = @expression_evaluator.evaluate(@parts_address)
    sign = address >=0 ? Sign::POSITIVE: Sign::NEGATIVE
    address = address.abs
    [sign, [address >> Limits::BITS_IN_BYTE, address & Limits::BYTE]]
  end

  def check_address
    @parsed_address = @expression_evaluator.evaluate(@parts_address) if @parsed_address == nil
    @parsed_address
  end

  def has_future_reference?
    return false if @parts_address == nil
    check_address.class <= FutureReference
  end

  def future_reference
    raise 'No future reference present'  if  !(check_address.class <= FutureReference )
    check_address.symbol
  end

end


class CpuInstruction < Instruction
  def as_word
    op_code = Instructions::OPERATION[@parts_op]
    f = Instructions::F_VALUE[@parts_op]
    f = extract_f if f == nil or @parts_f != nil
    i = extract_i

    sign , address = extract_address
    Word.new(sign, address + [i, f, op_code])
  end

  def extract_f
    (@parts_f != nil) ? @expression_evaluator.evaluate(@parts_f) : Instructions::F_DEFAULT[@parts_op]
  end

  def extract_i
    @parts_i != nil ? @parts_i.to_i : 0
  end
end