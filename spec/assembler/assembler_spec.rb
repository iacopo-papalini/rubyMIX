$:.unshift (File.dirname(__FILE__) + '/../../src/')
$:.unshift (File.dirname(__FILE__) + '/../../generated/')
require 'rspec'
require 'word'
require 'assembler/instruction_parser'
require 'assembler/assembler'
require 'instructions'

describe 'Convert an assembly program and store in memory' do
  before(:each) do
    @assembler = Assembler.new
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
  it 'should parse a line with the ORIG meta instruction' do
    @assembler.parse_line ' ORIG 3000'
    @assembler.set_memory_locations.count.should eq 0
    @assembler.location_counter.should eq 3000
  end

  #noinspection RubyResolve
  it 'should parse a line after the ORIG meta instruction and set its LOC as a global' do
    @assembler.parse_line ' ORIG 3000'
    @assembler.parse_line ' NOP'
    @assembler.parse_line 'TEST NOP'
    @assembler.set_memory_locations.count.should eq 2
    @assembler.constants['TEST'].should eq 3001
  end

  #noinspection RubyResolve
  it 'should correctly resolve symbolics addresses' , :broken => true do
    @assembler.parse_line ' ORIG 3000'
    @assembler.parse_line 'TEST NOP'
    @assembler.parse_line ' JMP TEST+5'
    fail('Check instruction parsing result')

  end
end
