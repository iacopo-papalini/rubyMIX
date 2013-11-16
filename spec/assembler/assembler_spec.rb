require File.dirname(__FILE__) +'/../../src/autoload.rb'
require 'rspec'

RSpec.configure do |c|
  # declare an exclusion filter
  c.filter_run_excluding :broken => true
end

describe 'Convert an assembly program and store in memory' do
  before(:each) do
    @assembler = Assembler.new
    @instruction_parser = InstructionParser.new()
    @instruction_parser.expression_evaluator = ExpressionParser.new(nil)
  end

  #noinspection RubyResolve
  it 'should parse a line with a constant definition' do
    @assembler.parse_line 'XX EQU 1000'
    @assembler.set_memory_locations.count.should eq 0
    @assembler.constants['XX'].should eq 1000
  end

  it 'should check that an EQU instruction has a constant name' do
    expect {
      #noinspection RubyResolve
      @assembler.parse_line ' EQU 1000' }.to raise_error
  end

  #noinspection RubyResolve
  it 'should parse a line with a data CON definition' do
    @assembler.parse_lines [' ORIG 3000', 'XX CON -64', 'TEST NOP']
    @assembler.set_memory_locations.count.should eq 2
    @assembler.set_memory_locations[3001].should eq @instruction_parser.as_word('NOP')
    @assembler.set_memory_locations[3000].should eq Word.new(Sign::NEGATIVE, [0,0,0,1,0])



  end

  #noinspection RubyResolve
  it 'should parse a line with the ORIG meta instruction' do
    @assembler.parse_line ' ORIG 3000'
    @assembler.set_memory_locations.count.should eq 0
    @assembler.location_counter.should eq 3000
  end

  #noinspection RubyResolve
  it 'should parse a line after the ORIG meta instruction and set its LOC as a global' do
    @assembler.parse_lines [' ORIG 3000', ' NOP', 'TEST NOP']
    @assembler.set_memory_locations.count.should eq 2
    @assembler.constants['TEST'].should eq 3001
  end

  #noinspection RubyResolve
  it 'should correctly resolve symbolics addresses' do
    @assembler.parse_lines [' ORIG 3000', 'TEST NOP', ' JMP TEST+5']
    @assembler.set_memory_locations[3001].should eq @instruction_parser.as_word('JMP 3005')
  end

  #noinspection RubyResolve
  it 'should correctly parse many lines' do
    lines = [' ORIG 3000', 'TEST NOP', ' JMP TEST+5']
    @assembler.parse_lines lines
    @assembler.set_memory_locations[3001].should eq @instruction_parser.as_word('JMP 3005')
  end
  #noinspection RubyResolve
  it 'should correctly resolve a future reference' do
    lines = [' ORIG 3000', ' JMP TEST+5', ' STA 1', ' STA 2', ' STA 3', ' STA 4', 'TEST STA 65', ' STA 5']
    @assembler.parse_lines lines
    @assembler.set_memory_locations[3000].should eq @instruction_parser.as_word('JMP 3010')
    @assembler.set_memory_locations[3006].should eq @instruction_parser.as_word('STA 5')
  end
  #noinspection RubyResolve
  it 'should correctly resolve two nested future references' do
    lines = [' ORIG 3000', ' JMP TEST+5', ' STA 1', ' STA TEST2', 'TEST2 STA 3', ' STA 4', 'TEST STA 65', ' STA 5']
    @assembler.parse_lines lines
    @assembler.set_memory_locations[3000].should eq @instruction_parser.as_word('JMP 3010')
    @assembler.set_memory_locations[3001].should eq @instruction_parser.as_word('STA 1')
    @assembler.set_memory_locations[3002].should eq @instruction_parser.as_word('STA 3003')
    @assembler.set_memory_locations[3003].should eq @instruction_parser.as_word('STA 3')
    @assembler.set_memory_locations[3004].should eq @instruction_parser.as_word('STA 4')
    @assembler.set_memory_locations[3005].should eq @instruction_parser.as_word('STA 65')
    @assembler.set_memory_locations[3006].should eq @instruction_parser.as_word('STA 5')
  end

  #noinspection RubyResolve
  it 'should correctly resolve two interleaved future references' do
    lines = [' ORIG 3000', ' JMP TEST+5', ' STA 1', ' STA TEST2', 'TEST STA 3', ' STA 4', 'TEST2 STA 65', ' STA 5']
    @assembler.parse_lines lines
    @assembler.set_memory_locations[3000].should eq @instruction_parser.as_word('JMP 3008')
    @assembler.set_memory_locations[3001].should eq @instruction_parser.as_word('STA 1')
    @assembler.set_memory_locations[3002].should eq @instruction_parser.as_word('STA 3005')
    @assembler.set_memory_locations[3003].should eq @instruction_parser.as_word('STA 3')
    @assembler.set_memory_locations[3004].should eq @instruction_parser.as_word('STA 4')
    @assembler.set_memory_locations[3005].should eq @instruction_parser.as_word('STA 65')
    @assembler.set_memory_locations[3006].should eq @instruction_parser.as_word('STA 5')
  end

  #noinspection RubyResolve
  it 'should correctly stop parsing with END' do
    lines = [' ORIG 3000', 'START NOP', 'TEST NOP', ' JMP TEST+5', ' END START']
    @assembler.parse_lines lines
    @assembler.starting_ip.should eq 3000
  end

  #noinspection RubyResolve
  it 'should initialize and run a MIX cpu' do
    lines = [' ORIG 3000', 'START STA 1', 'TEST NOP', ' JMP TEST+5', ' END START']
    @assembler.parse_lines lines

    mix = MixCore.new
    @assembler.load_cpu mix
    mix.ip.should eq  3000
    mix.memory[3000].should eq @instruction_parser.as_word('STA 1')
  end

  #noinspection RubyResolve
  it 'should skip a comment' do
    lines = [' ORIG 3000', ' JMP TEST+5', '* ignore me', ' STA 1', 'TEST STA 3']
    @assembler.parse_lines lines
    @assembler.set_memory_locations[3000].should eq @instruction_parser.as_word('JMP 3007')
    @assembler.set_memory_locations[3001].should eq @instruction_parser.as_word('STA 1')
    @assembler.set_memory_locations[3002].should eq @instruction_parser.as_word('STA 3')
  end

end
