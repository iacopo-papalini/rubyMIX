require 'rspec/core/rake_task'
require './src/generator/abstract_generator'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '-P src/ -r ./spec_helper.rb   -r ./spec/formatters/junit.rb -f JUnit -o results.xml'

end

generated_dir = './generated'

task :prepare_directory do
  Dir.mkdir(generated_dir)   if not File.exist? generated_dir
end


task :generate_assembly  => :prepare_directory do
  require './src/generator/assembly_descriptor_generator'
  gen =  AssemblyDescriptorGenerator.new './src/instruction-codes.yml'
  file = File.open(generated_dir+'/instructions.rb', 'w')
  file.write gen.generate
  file.close

  end
task :generate_devices_descriptors  => :prepare_directory do
  require './src/generator/devices_descriptors_generator'
  gen =  DevicesDescriptorGenerator.new './src/io_devices.yml'
  file = File.open(generated_dir+'/devices.rb', 'w')
  file.write gen.generate
  file.close

end


task :generate => [:generate_devices_descriptors, :generate_assembly]
task :default => [:generate, :spec]