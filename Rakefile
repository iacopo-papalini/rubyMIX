require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '-P src/ -r ./spec_helper.rb   -r ./spec/formatters/junit.rb -f JUnit -o results.xml'

end
task :generate   do
  require './src/assembly_descriptor_generator'
  gen =  AssemblyDescriptorGenerator.new './src/instruction-codes.yml'
  file = File.open('./generated/instructions.rb', 'w')
  file.write gen.generate
  file.close

end


task :default => [:generate, :spec]