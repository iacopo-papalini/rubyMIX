require 'simplecov'
require 'simplecov-gem-adapter'
SimpleCov.start 'gem' do
  @filters = []
  add_filter('spec/')
  add_filter('/var/lib')

end