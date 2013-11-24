class MetaInstruction < Instruction

  #noinspection RubyResolve
  def value
    raise 'Empty address' if @parts_address == nil
    @expression_evaluator.evaluate(@parts_address)
  end

  #noinspection RubyResolve
  def code
    @parts_op
  end

  def as_word
    nil
  end
end

class EQUInstruction < MetaInstruction

  def execute_interactive_command(assembler, symbol)
    raise 'Constant name needed for EQU instruction' if symbol == nil
    assembler.define_constant(symbol, value)
  end
end

class ORIGInstruction < MetaInstruction
  def  initialize(parts)
    super(parts)
  end
  def execute_interactive_command(assembler, symbol)
    assembler.define_constant(symbol, assembler.location_counter) if symbol != nil
    assembler.location_counter = value
  end
end

class ENDInstruction < MetaInstruction
  def  initialize(parts)
    super(parts)
  end
  def execute_interactive_command(assembler, _)
    assembler.starting_ip = value
    assembler.create_unresolved_future_references
  end
end

class CONInstruction < MetaInstruction
  def  initialize(parts)
    super(parts)
  end
  def execute_interactive_command(_, _)
    nil
  end

  def as_word
    #noinspection RubyResolve
    Word.new().store_long(@expression_evaluator.evaluate(@parts_address))
  end
end

class ALFInstruction < MetaInstruction
  def  initialize(parts)
    super(parts)
  end
  def execute_interactive_command(_, _)
    nil
  end

  def as_word
    #noinspection RubyResolve
    Word.new().store_string(@parts_address.sub('_', ' '))
  end

  def has_future_reference?
    false
  end
end
