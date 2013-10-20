require 'yaml'

class Assembler
  DEFAULT_F = 5

  def initialize
    # See The Art Of Computer Programming V.1 pag 128
    @regexp = /^(?<OP>[A-Z][A-Z0-9]+)\s*(((?<SIGN>[-])?(?<ADDRESS>[0-9]{1,4}))?(,(?<I>[0-9]))?(\(((?<Fl>([0-5])):(?<Fr>[0-9])?)\))?)?$/
  end


  def as_word(line)
    parts = @regexp.match line
    raise if parts == nil
    op_code = Instructions::OPERATION[parts['OP']]
    f = Instructions::F_VALUE[parts['OP']]
    f = extract_f parts if f == nil or parts['Fl'] != nil
    i = extract_i parts

    sign = extract_sign parts
    address = extract_address parts

    Word.new(sign, address + [i, f, op_code])
  end

  def extract_address(parts)
    if parts['ADDRESS'] == nil
      return [0, 0]
    end
    address = parts['ADDRESS'].to_i
    [address >> Limits::BITS_IN_BYTE, address & Limits::BYTE]
  end

  def extract_sign(parts)
    parts['SIGN'] != '-' ? Sign::POSITIVE : Sign::NEGATIVE
  end

  def extract_f(parts)
    parts['Fl'] != nil ? 8* parts['Fl'].to_i + parts['Fr'].to_i : DEFAULT_F
  end

  def extract_i(parts)
    parts['I'] != nil ? parts['I'].to_i : 0
  end
end