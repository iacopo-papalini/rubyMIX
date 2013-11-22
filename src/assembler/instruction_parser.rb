require 'yaml'

class InstructionParser
  attr_writer :expression_evaluator



  def initialize
    # See The Art Of Computer Programming V.1 pag 128
    @word_regexp = /(?<OP>[A-Z][A-Z0-9]+)\s*(((?<ADDRESS>\-?[^,\(\s]+))?(,(?<I>[0-9]))?(\((?<F>[^\)]+)\))?)?/
    @expression_evaluator = nil
  end

  def as_instruction(line)
    parts = @word_regexp.match line
    raise("Invalid line: #{line}") if parts == nil
    if  is_meta_instruction? parts['OP']
      class_name = parts['OP'] + 'Instruction'
      ret = Kernel.const_get(class_name).new(parts)
    else
      ret = CpuInstruction.new(parts)
    end
    ret.expression_evaluator = @expression_evaluator
    ret
  end

  def is_meta_instruction?(operation)
    raise 'Operation %s not defined' % operation if not Instructions::OPERATION.has_key? operation
    Instructions::OPERATION[operation] >= Instructions::OP_EQU
  end

  def as_word(line)
    as_instruction(line).as_word
  end

end