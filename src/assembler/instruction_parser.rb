require 'yaml'

class InstructionParser
  DEFAULT_F = 5
  attr_writer :expression_evaluator

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
  end

  class CpuInstruction < Instruction
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

  def initialize
    # See The Art Of Computer Programming V.1 pag 128
    @word_regexp = /(?<OP>[A-Z][A-Z0-9]+)\s*(((?<SIGN>[-])?(?<ADDRESS>[^,\(\s]+))?(,(?<I>[0-9]))?(\((?<F>[^\)]+)\))?)?/
    @expression_evaluator = nil
  end

  def as_instruction(line)
    parts = @word_regexp.match line
    raise("Invalid line: #{line}") if parts == nil
    if  is_meta_instruction? parts['OP']
      ret = MetaInstruction.new(parts)
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