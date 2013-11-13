$:.unshift (File.dirname(__FILE__))
$:.unshift (File.dirname(__FILE__) + '/../generated/')

require 'mix_core'
require 'word'
require 'assembler/assembler'
require 'assembler/instruction_parser'
require 'assembler/expression_parser'
require 'register'
require 'instructions'

assembler = Assembler.new
mix = MixCore.new
program = File.dirname(__FILE__) + '/../examples/1-fibonacci.mix'


assembler.parse_lines File.open(program, 'r')
assembler.load_cpu(mix)
print mix.ip.to_s + "\n"
until mix.halt do
  mix.clock
  break if mix.overflow
end

(3000..3030).each do |i|
  print mix.memory[i].long.to_s << ' '
end
print "\n"