$:.unshift (File.dirname(__FILE__))

require 'mix_core'
require 'word'
require 'assembler'
require 'register'
require 'assembly_descriptor_generator'


gen = AssemblyDescriptorGenerator.new File.dirname(__FILE__) + '/instruction-codes.yml'


program = [
    'ENT1 100',
    'ENTA 200',
    'INCA 1,1']

assembler = Assembler.new
mix = MixCore.new
base = 3000
program.each_with_index do |line, i|
  command = assembler.as_word(line)
  mix.change_memory_word(base + i, command)
end

mix.ip = base

program.each do
  mix.clock
end

print ' ' << mix.ra.long.to_s << "\n"

