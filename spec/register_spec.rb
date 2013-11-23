require File.dirname(__FILE__) +'/../src/autoload.rb'
require 'rspec'

# See page 127 of 'The Art of Computer Programming, Vol. 1'
describe 'Register' do
  before(:each) do
    @bytes = [2, 32, 3, 5, 4]
    @word = Word.new(Sign::NEGATIVE, @bytes)
  end
  it 'should allow full word copy' do
    t = LongRegister.new(:test)
    t.load_value(@word)
    t.bytes.should eq @bytes
    t.sign.should eq Sign::NEGATIVE
  end
  it 'should allow (1:5) copy' do
    t = LongRegister.new (:test)
    t.load_value(@word, 1)
    t.bytes.should eq @bytes
    t.sign.should eq Sign::POSITIVE
  end

  it 'should allow (3:5) copy' do
    t = LongRegister.new (:test)
    t.load_value(@word, 3, 5)
    t.bytes.should eq [0, 0, 3, 5, 4]
    t.sign.should eq Sign::POSITIVE
  end
  it 'should allow (0:3) copy' do
    t = LongRegister.new (:test)
    t.load_value(@word, 0, 3)
    t.bytes.should eq [0,0,2,32,3]
    t.sign.should eq Sign::NEGATIVE

  end
  it 'should allow (4:4) copy' do
    t = LongRegister.new (:test)
    t.load_value(@word, 4, 4)
    t.bytes.should eq [0, 0, 0, 0, 5]
    t.sign.should eq Sign::POSITIVE
  end
  it 'should allow (0:0) copy' do
    t = LongRegister.new (:test)
    t.load_value(@word, 0, 0)
    t.bytes.should eq [0, 0, 0, 0, 0]
    t.sign.should eq Sign::NEGATIVE
  end
end

describe 'Big' do

  it 'should have 5 bytes' do
    LongRegister.new(:test).size.should eq 5
  end


end

describe 'Small' do
  it 'should have 2 bytes' do
    ShortRegister.new(:test).size.should eq 2
  end
end

describe 'Jump' do
  it 'should have 2 bytes' do
    JumpRegister.new.size.should eq 2
  end
end
