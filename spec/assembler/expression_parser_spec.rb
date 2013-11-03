$:.unshift (File.dirname(__FILE__) + '/../../src/')
$:.unshift (File.dirname(__FILE__) + '/../../generated/')
require 'rspec'
require 'rspec/mocks'
require 'assembler/expression_parser'

describe 'Parses MIXAL expressions' do
  before(:each) do
    @mock_evaluator = double(Class)
    @mock_evaluator.stub(:resolve_symbol)
    @parser = ExpressionParser.new(@mock_evaluator)

  end
  it 'should parse a symbol' do
    @parser.is_symbol('44X3').should eq true
    @parser.is_symbol('443').should eq false
    @parser.is_symbol('CUCCUMA').should eq true
    @parser.is_symbol('CUCCUMACUCCUMA').should eq false
    @parser.is_symbol('CUCCUMA CUCCUMA').should eq false
    @parser.is_symbol('X').should eq true
  end

  it 'should parse a number' do
    @parser.is_number('44X3').should eq false
    @parser.is_number('443').should eq true
  end

  it 'should recognise a asterisk' do
    @parser.is_asterisk('*').should eq true
  end

  it 'should evaluate a symbol' do
    @mock_evaluator.should_receive(:resolve_symbol).with('CIRO').and_return(1)
    @parser.evaluate('CIRO').should eq 1
  end
  it 'should evaluate an asterisk' do
    @mock_evaluator.should_receive(:resolve_symbol).with('*').and_return(1)
    @parser.evaluate('*').should eq 1
  end
  it 'should evaluate a number' do
    @parser.evaluate('1').should eq 1
  end
  it 'should evaluate a plus number' do
    @parser.evaluate('+1').should eq 1
  end
  it 'should evaluate a minus number' do
    @mock_evaluator.should_receive(:resolve_symbol).with('CIRO').and_return(1)
    @parser.evaluate('-CIRO').should eq -1
  end

  it 'should evaluate an expression with *' do
    @mock_evaluator.should_receive(:resolve_symbol).with('CIRO').and_return(10)
    @parser.evaluate('CIRO*5').should eq 50
  end
  it 'should evaluate an expression with +' do
    @mock_evaluator.should_receive(:resolve_symbol).with('CIRO').and_return(10)
    @parser.evaluate('5+CIRO').should eq 15
  end
  it 'should evaluate an expression with -' do
    @mock_evaluator.should_receive(:resolve_symbol).with('CIRO').and_return(10)
    @parser.evaluate('5-CIRO').should eq -5
  end
  it 'should evaluate an expression with /' do
    @mock_evaluator.should_receive(:resolve_symbol).with('CIRO').and_return(10)
    @parser.evaluate('CIRO/5').should eq 2
  end
  it 'should evaluate an expression with :' do
    @parser.evaluate('1:3').should eq 11
  end
  it 'should evaluate a fairly complex expression' do
    @parser.evaluate('-1+5*20/6').should eq 13
  end
  it 'should evaluate a triple asterisk expression' do
    @mock_evaluator.should_receive(:resolve_symbol).with('*').and_return(2)
    @mock_evaluator.should_receive(:resolve_symbol).with('*').and_return(2)
    @parser.evaluate('***').should eq 4
  end
  it 'should evaluate an asterisk expression' do
    @mock_evaluator.should_receive(:resolve_symbol).with('*').and_return(7)
    @parser.evaluate('*-3').should eq 4
  end

end