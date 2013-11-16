class AbstractUnit

  def initialize(cpu)
    @cpu = cpu
   end

  def extract_op_code_and_modifier(instruction)
    return instruction.bytes[4], instruction.bytes[3]
  end

  def extract_word_from_memory(instruction)
    modified_address = calculate_modified_address(instruction)
    @cpu.mu.fetch(modified_address)
  end

  def calculate_modified_address(instruction)
    i = instruction.bytes[2]
    modified_address = instruction.long(0, 2)
    modified_address + ((i > 0) ? @cpu.ri[i-1].long : 0)
  end

  def explode_f(f)
    left = f / 8
    right = f % 8
    return left, right
  end

  def select_register_from_op_code(op_code, base)
    index = op_code - base
    case index
      when 0
        register = @cpu.ra
      when 1..6
        register = @cpu.ri[index - 1]
      when 7
        register = @cpu.rx
      when 8
        register = @cpu.rj
      else
        raise 'Cannot select register from index %d' % index
    end
    register
  end

end