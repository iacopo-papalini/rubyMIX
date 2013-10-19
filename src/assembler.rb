require 'yaml'

class Assembler
  DEFAULT_F = 5

  def initialize
    # See The Art Of Computer Programming V.1 pag 128
    @regexp = /^(?<OP>[A-Z][A-Z0-9]+)\s*(((?<SIGN>[-])?(?<ADDRESS>[0-9]{1,4}))?(,(?<I>[0-9]))?(\(((?<Fl>([0-5])):(?<Fr>[0-9])?)\))?)?$/
    @codes = YAML.load_file(File.dirname(__FILE__) + '/instruction-codes.yml')['instructions']

    @codes_to_op_codes = {}
    @codes.each_with_index do |code, opCode|
      if code.is_a?(Array) then
        code.each_with_index do |realCode, f|
          @codes_to_op_codes[realCode] = [opCode, f]
        end
      else
        @codes_to_op_codes[code] = [opCode, DEFAULT_F]
      end
    end
  end

  def as_word(line)
    parts = @regexp.match line
    raise if parts == nil
    op_code, f = @codes_to_op_codes[parts['OP']]
    i = extract_i parts
    if f == DEFAULT_F or parts['Fl'] != nil
      f = extract_f parts, f
    end
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

  def extract_f(parts, f)
    parts['Fl'] != nil ? 8* parts['Fl'].to_i + parts['Fr'].to_i : f
  end

  def extract_i(parts)
    parts['I'] != nil ? parts['I'].to_i : 0
  end
end