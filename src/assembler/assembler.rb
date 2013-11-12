require 'logger'

class Assembler
  attr_reader :set_memory_locations
  attr_reader :constants
  attr_reader :location_counter
  attr_reader :starting_ip

  def initialize
    @parser = InstructionParser.new
    @parser.expression_evaluator = ExpressionParser.new(self)

    # See The Art Of Computer Programming V.1 pag 153
    @line_regexp = /(?<LOC>[A-Z0-9]{1,10})?\s(?<INSTRUCTION>.+)(#(?<REMARKS>.*)\s+)?/
    @constants = {}
    @set_memory_locations = {}
    @location_counter = 0

    @lines = nil
    @current_line = nil
    @logger = Logger.new(STDOUT)
    @starting_ip = nil
  end

  def parse_lines (lines)
    @current_line = -1
    @lines = lines

    until finished? do
      parse_next_line
    end
  end


  def parse_line (line, location = @location_counter)
    @logger.debug 'Parsing line <%s>, location counter: %d' % [line.strip, location]
    parts = @line_regexp.match line
    instruction = @parser.as_instruction (parts['INSTRUCTION'])
    if instruction.class == InstructionParser::MetaInstruction
      self.send('execute_meta_instruction_' + instruction.code.downcase, parts, instruction)
      return [nil, nil]
    end
    [instruction, parts['LOC']]
  end


  def resolve_symbol(string)
    return constants[string] if  @constants.has_key?(string)
    parse_until_found_or_end(string)

    raise 'Symbol %s not found ' % string if !@constants.has_key? string
    constants[string]
  end

  def load_cpu(mix_core)
     raise 'END statement not yet reached' if @starting_ip == nil
    mix_core.ip = @starting_ip
    set_memory_locations.each do  |address, word|
         mix_core.memory[address].store_value(word)
    end
  end

  private

  def parse_next_line
    @current_line += 1
    instruction, defined_symbol = parse_line(next_line_contents, @location_counter)
    if instruction != nil
      set_memory_location(@location_counter, instruction.as_word)
      store_address_in_globals(defined_symbol, @location_counter) if defined_symbol != nil
      @location_counter += 1
    end
  end

  def next_line_contents
    if @lines.respond_to? :gets
      return @lines.gets
    end
    @lines[@current_line]
  end

  def finished?
     return @lines.eof? if (@lines.respond_to? :eof)
    (@current_line >= (@lines.count - 1)) or (@starting_ip != nil)
  end

  def set_memory_location(location, word)
    @set_memory_locations[location] = word
    @logger.debug 'Set in memory at location %d = %s' %[location, word]
  end

  def store_address_in_globals(global_address, location)
    if global_address != nil
      @constants[global_address] = location
    end
  end

  def execute_meta_instruction_equ(parts, instruction)
    raise 'Constant name needed for EQU instruction at line %d' % @current_line if parts['LOC'] == nil
    @constants[parts['LOC']] = instruction.value
  end

  def execute_meta_instruction_orig(_, instruction)
    @location_counter = instruction.value
  end

  def execute_meta_instruction_end(_, instruction)
    @starting_ip = instruction.value
  end

  def parse_until_found_or_end(symbol)
    # That's tricky: this method is called recursively by resolve_symbol and _before_ the @location_counter
    # has been increased (see method parse_next_line). So we need to let the parsing skip the current line
    @location_counter += 1
    while !@constants.has_key?(symbol) and not finished? do
      parse_next_line
    end
    # See before: now we need to decrease the location counter so that no location is left empty
    @location_counter -= 1
  end
end