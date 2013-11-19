class MetaInstruction < Instruction

  def value
    raise 'Empty address' if @parts_address == nil
    @expression_evaluator.evaluate(@parts_address)
  end

  def code
    @parts_op
  end

  def as_word
    nil
  end
end

class EQUInstruction < MetaInstruction

  def execute(assembler, symbol)
    raise 'Constant name needed for EQU instruction' if symbol == nil
    assembler.define_constant(symbol, value)
  end
end

class ORIGInstruction < MetaInstruction
  def  initialize(parts)
    super(parts)
  end
  def execute(assembler, _)
    assembler.location_counter = value
  end
end

class ENDInstruction < MetaInstruction
  def  initialize(parts)
    super(parts)
  end
  def execute(assembler, _)
    assembler.starting_ip = value
  end
end

class CONInstruction < MetaInstruction
  def  initialize(parts)
    super(parts)
  end
  def execute(_, _)
    nil
  end

  def as_word
    sign = extract_sign
    address = extract_address
    Word.new(sign, [0, 0, 0] +address)
  end
end

