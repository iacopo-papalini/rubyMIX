require 'core/unit/abstract_unit'
class ControlUnit < AbstractUnit
  attr_accessor :rj
  attr_accessor :ip
  attr_accessor :halt

  def initialize(cpu, logger)
    # Just to let IntelliJ detect the field, otherwise it keeps complaining
    @cpu = nil
    @logger = nil
    super(cpu, logger)
    reset
  end

  def reset
    @rj = JumpRegister.new
    @ip = 0
    @halt = false
  end

  def increase_ip
    @ip = (@ip + 1) % @cpu.memory_size if not @halt
  end

  def jump(instruction)
    _, f = extract_op_code_and_modifier(instruction)
    address = calculate_modified_address(instruction)

    skip = should_perform_jump(f) ? false : true

    return if skip
    perform_jump(address, f != Instructions::F_JSJ)
  end

  def jump_check_register(instruction)
    op_code, f = extract_op_code_and_modifier(instruction)
    register = select_register_from_op_code(op_code, Instructions::OP_JAN)
    address = calculate_modified_address(instruction)

    perform = should_perform_jump_register(f, register)

    return if !perform
    perform_jump address, true
  end

  def perform_jump(address, update_rj)
    @rj.store_long(@ip + 1) if update_rj
    @ip = address - 1 # since ip gets increased every clock
  end

  def should_perform_jump(f)
    alu = @cpu.alu
    return false if (f == Instructions::F_JOV and alu.overflow == false)
    return false if (f == Instructions::F_JNOV and alu.overflow == true)
    return false if (f == Instructions::F_JL and !alu.less)
    return false if (f == Instructions::F_JE and !alu.equal)
    return false if (f == Instructions::F_JG and !alu.greater)
    return false if (f == Instructions::F_JGE and !alu.greater_or_equal)
    return false if (f == Instructions::F_JNE and alu.equal)
    return false if (f == Instructions::F_JLE and !alu.lesser_or_equal)

    true
  end


  def should_perform_jump_register(f, register)
    return false if f == Instructions::F_JAN and register.long >= 0
    return false if f == Instructions::F_JAZ and register.long != 0
    return false if f == Instructions::F_JAP and register.long <= 0
    return false if f == Instructions::F_JANN and register.long < 0
    return false if f == Instructions::F_JANZ and register.long == 0
    return false if f == Instructions::F_JANP and register.long > 0
    true
  end

  def generic_operation(instruction)
    _, f = extract_op_code_and_modifier(instruction)
    case f
      when Instructions::F_HLT
        @halt = true
        @ip = nil

      when Instructions::F_CHAR
        ra = @cpu.ra.long
        @cpu.ra.store_string('%05d' % (ra/ 100000))
        @cpu.rx.store_string('%05d' % (ra% 100000))
      when Instructions::F_NUM
        tmp = @cpu.ra.bytes + @cpu.rx.bytes
        sum = 0
        tmp.each do |byte|
          sum = sum * 10 + byte % 10
        end
        if sum > Limits::MAX_INT
          sum = Limits::MAX_INT
          @cpu.alu.overflow = true
        end

        @cpu.ra.store_long(sum)
      else
        raise 'Unimplemented instruction '+ instruction.to_s
    end
  end

end