$:.unshift (File.dirname(__FILE__))
$:.unshift (File.dirname(__FILE__) + '/../generated/')

require 'mix_core'
require 'word'
require 'assembler/assembler'
require 'assembler/disassembler'
require 'assembler/instruction_parser'
require 'assembler/expression_parser'
require 'register'
require 'instructions'

disassembler = Disassembler.new
assembler = Assembler.new
mix = MixCore.new
mix.disassembler = disassembler
assembler.disassembler = disassembler
#program = '1-fibonacci.mix'
program ='2-500primes.mix'
file = File.dirname(__FILE__) + '/../examples/' + program


assembler.parse_lines File.open(file, 'r')
assembler.load_cpu(mix)
print mix.ip.to_s + "\n"
until mix.halt do
  mix.clock
end

(3000..3031).each do |i|
  print mix.memory[i].long.to_s << ' '
end
print "\n"