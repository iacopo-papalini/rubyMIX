class Instruction
  attr_writer :expression_evaluator

  def initialize(parts)
    @parts = parts
    @expression_evaluator = nil
  end

  def extract_address
    address_string = @parts['ADDRESS']
    if address_string == nil
      return [0, 0]
    end
    address = @expression_evaluator.evaluate(address_string)
    [address >> Limits::BITS_IN_BYTE, address & Limits::BYTE]
  end

  def extract_sign
    @parts['SIGN'] != '-' ? Sign::POSITIVE : Sign::NEGATIVE
  end

end

class MetaInstruction < Instruction
  def value
    Word.new(extract_sign, [0, 0, 0] + extract_address).long
  end

  def code
    @parts['OP']
  end

  def equ(assembler, parts, instruction)
    raise 'Constant name needed for EQU instruction' if parts['LOC'] == nil
    assembler.define_constant(parts['LOC'], instruction.value)
    nil
  end

  def orig(assembler,_, instruction)
    assembler.location_counter = instruction.value
    nil
  end

  def end(assembler,_, instruction)
    assembler.starting_ip = instruction.value
    nil
  end

  def con(_,_, instruction)
    sign = instruction.extract_sign
    address = instruction.extract_address

    Word.new(sign, [0,0,0] +address )
  end
end

class CpuInstruction < Instruction
  DEFAULT_F = 5
  def as_word
    op_code = Instructions::OPERATION[@parts['OP']]
    f = Instructions::F_VALUE[@parts['OP']]
    f = extract_f if f == nil or @parts['F'] != nil
    i = extract_i

    sign = extract_sign
    address = extract_address

    Word.new(sign, address + [i, f, op_code])
  end

  def extract_f
    @parts['F'] != nil ? @expression_evaluator.evaluate(@parts['F']) : DEFAULT_F
  end

  def extract_i
    @parts['I'] != nil ? @parts['I'].to_i : 0
  end
end