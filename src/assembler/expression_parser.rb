require 'assembler/future_reference'

class ExpressionParser
  BINARY_OPERATION_SPLIT_REGEXP = /^(?<LEFT>[^\/]+)(?<OP>\+|\-|\*|\/{1,2}|:)(?<RIGHT>.+)$/

  def initialize(symbol_resolver)
    @symbol_resolver = symbol_resolver
  end

  def is_symbol(string)
    (string =~ /^[A-Z0-9]{1,10}$/) != nil && (string =~ /[A-Z]/) != nil

  end

  def is_number(string)
    (string =~ /^(\+|\-)?[0-9]{1,10}$/) != nil
  end

  def is_asterisk(string)
    string =='*'
  end

  def evaluate(string)
    single_token = evaluate_single_token(string)
    return single_token if single_token != nil

    string = adjust_negative_value(string)
    evaluate_expression(string)
  end

  def evaluate_expression(string)
    left, operation, right = split_expression(string)
    evaluate_binary_operation(left, operation, right)
  end

  def adjust_negative_value(string)
    string[0] == '-' ? '0' + string : string
  end

  BINARY_OPERATIONS = {
      '+' => lambda{| x,y | x + y},
      '-' => lambda{| x,y | x - y},
      '*' => lambda{| x,y | x * y},
      '/' => lambda{| x,y | x / y},
      ':' => lambda{| x,y | 8 * x + y},
      '//'=> lambda{ raise 'Operation not implemented' }
  }
  def evaluate_binary_operation(left, operation, right)
    raise 'Unknown Operation ' + operation  if ! BINARY_OPERATIONS.has_key? operation

    BINARY_OPERATIONS[operation].call(left, right)
  end


  def split_expression(string)
    parts = BINARY_OPERATION_SPLIT_REGEXP.match string
    raise 'Invalid expression ' + string if parts == nil
    right = evaluate_single_token(parts['RIGHT'])
    raise 'Invalid sub expression ' + parts['RIGHT'] if right.class < FutureReference
    left = evaluate(parts['LEFT'])
    operation = parts['OP']
    return left, operation, right
  end

  def evaluate_single_token(string)
    #noinspection RubyResolve
    return @symbol_resolver.resolve_constant(string) if is_symbol string or is_asterisk string
    return string.to_i if is_number string

    return evaluate(string[1.. -1]) if string[0] == '+'
    nil
  end
end