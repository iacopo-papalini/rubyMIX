require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '-P src/ -r ./spec_helper.rb   -r ./spec/formatterd/junit.rb -f JUnit -o results.xml'

end

task :default => :spec