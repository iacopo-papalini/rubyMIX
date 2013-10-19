require 'rspec/core/rake_task'
require 'simplecov'

RSpec::Core::RakeTask.new(:spec) do |t|
  SimpleCov.start do
    add_filter 'spec/'
  end
  t.rspec_opts = '-P src/'

end

task :default => :spec