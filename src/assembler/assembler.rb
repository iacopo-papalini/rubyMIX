require 'logger'

class Assembler
  attr_reader :set_memory_locations
  attr_reader :constants
  attr_accessor :location_counter
  attr_accessor :starting_ip
  attr_writer :disassembler
  LINE_REGEXP = /(?<LOC>[A-Z0-9]{1,10})?\s(?<INSTRUCTION>.+)(#(?<REMARKS>.*)\s+)?/

  def initialize
    @parser = InstructionParser.new
    @parser.expression_evaluator = ExpressionParser.new(self)

    # See The Art Of Computer Programming V.1 pag 153
    @constants = {}
    @set_memory_locations = {}
    @location_counter = 0
    @disassembler = nil
    @iterator = nil

    @logger = Logger.new(STDOUT)
    @starting_ip = nil
  end

  class LineIterator
    def initialize(source)
      @lines = source
      @current_line = -1
    end

    def finished?
      return @lines.eof? if (@lines.respond_to? :eof)
      (@current_line >= (@lines.count - 1))
    end

    def next_line_contents
      @current_line += 1
      if @lines.respond_to? :gets
        return @lines.gets
      end
      @lines[@current_line]
    end
  end


  def finished?
    @iterator.finished? or (@starting_ip != nil)
  end


  def parse_lines (lines)
    @iterator = LineIterator.new(lines)

    until finished? do
      parse_next_line
    end
  end


  def parse_line (line, location = @location_counter)
    return [nil, nil] if line[0] =='*'

    @logger.debug 'Parsing line <%s>, location counter: %d' % [line.strip, location]
    parts = LINE_REGEXP.match line
    instruction = @parser.as_instruction (parts['INSTRUCTION'])
    assemble_line(instruction, parts)
  end

  def resolve_symbol(string)
    return constants[string] if  @constants.has_key?(string)
    parse_until_found_or_end(string)

    raise 'Symbol %s not found ' % string if !@constants.has_key? string
    constants[string]
  end

  def load_cpu(mix_core)
    raise 'END statement not yet reached' if @starting_ip == nil
    mix_core.force_instruction_pointer @starting_ip
    set_memory_locations.each do |address, word|
      mix_core.memory[address].store_value(word)
    end
  end

  def define_constant(name, value)
    @constants[name] = value
  end

  private

  def parse_next_line
    instruction, defined_symbol = parse_line(@iterator.next_line_contents, @location_counter)
    if instruction != nil
      set_memory_location(@location_counter, instruction.as_word)
      store_address_in_globals(defined_symbol, @location_counter) if defined_symbol != nil
      @location_counter += 1
    end
  end

  def assemble_line(instruction, parts)
    encoded_instruction = (instruction.class == MetaInstruction) ?
        instruction.send(instruction.code.downcase, self, parts, instruction) :
        instruction
    [encoded_instruction, parts['LOC']]

  end


  def set_memory_location(location, word)
    @set_memory_locations[location] = word
    if @logger.debug?
      @logger.debug 'Set in memory at location %d = %s (%s)' %[location, word, @disassembler.disassemble(word)] if @disassembler != nil
      @logger.debug 'Set in memory at location %d = %s' %[location, word] if @disassembler==nil
    end

  end

  def store_address_in_globals(global_address, location)
    if global_address != nil
      @constants[global_address] = location
    end
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