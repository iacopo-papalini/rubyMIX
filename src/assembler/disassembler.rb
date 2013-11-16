class Disassembler
  # To change this template use File | Settings | File Templates.
  def disassemble(word)
    op_code = word.bytes[4]
    f = word.bytes[3]
    address = word.long(0, 2)
    i = word.bytes[2]
    if Instructions::F_STR[op_code] != nil
      instruction = Instructions::F_STR[op_code][f]
    else
      instruction = Instructions::INSTRUCTION[op_code]
    end

    str = instruction

    str += ' ' + address.to_s if address != 0 or i!=0
    str += ',' + i.to_s if i != 0
    str += '(%d:%d)' % [f/8, f%8] if f!= CpuInstruction::DEFAULT_F and has_f(op_code)

    str
  end

  def has_f(op_code)
    op_code != Instructions::OP_NOP  and  Instructions::F_STR[op_code] == nil
  end
end