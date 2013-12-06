require 'yaml'

class AssemblyDescriptorGenerator   < AbstractGenerator



  def generate_class(class_name, constants_list)
    string = ''
    print "Generating class %s\n" %class_name
    string << "class %s\n\tOPERATION = {}\n\tINSTRUCTION = {}\n\tF_VALUE = {}\n\tF_STR = {}\n\tF_DEFAULT = {}\n" % class_name
    acc_operations = ''
    acc_f_values = ''

    constants_list.each_with_index do |code, op_code|
      operations, f_values = generate_code(code, op_code)
      print "Generated code for %s constant: (%d characters)\n" % [code, operations.length + f_values.length]
      acc_operations << operations
      acc_f_values << f_values
    end

    string << acc_operations
    string << acc_f_values
    string << "end\n"
  end

  DEFAULT_F = 5

  def generate_code(code, op_code)
    if code.is_a?(Array)
      multi_instructions_op_code(op_code, code)
    else
      if code =~ /^([A-Z0-9]+)\(([0-9]+)\)$/
        code = $1
        default_f = $2
      else
        default_f = DEFAULT_F
      end
      str = create_operation_constants(op_code, code)
      str += INDENT + "F_DEFAULT['%s'] = %d\n" % [code, default_f]
      [str, '']
    end
  end

  def multi_instructions_op_code(op_code, code)
    str_initialized = false
    operations = ''
    f_values = ''
    code.each_with_index do |realCode, f|
      next if realCode == nil
      operations << create_operation_constants(op_code, realCode)
      f_values << INDENT << ("F_STR[OP_%s] = {}\n" % realCode) if not str_initialized
      f_values << create_f_field_constants(f, realCode)
      str_initialized = true
    end
    [operations, f_values]
  end

  def create_f_field_constants(f, real_code)
    INDENT + ("F_%s = %d\n" % [real_code, f]) +
        INDENT + ("F_VALUE['%s'] = F_%s\n" % [real_code, real_code]) +
        INDENT + ("F_STR[OP_%s][F_%s] = '%s'\n" % [real_code, real_code, real_code])
  end

  def create_operation_constants(op_code, real_code)
    INDENT + ("OP_%s = %d\n" % [real_code, op_code]) +
        INDENT + ("OPERATION['%s'] = OP_%s\n" % [real_code, real_code]) +
        INDENT + ("INSTRUCTION[OP_%s] = '%s'\n" % [real_code, real_code])
  end
end
