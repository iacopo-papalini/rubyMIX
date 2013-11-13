require 'yaml'

class AssemblyDescriptorGenerator
  def initialize(file)
    @file = file
  end

  def generate
    data = YAML.load_file(@file)
    string = ''
    data.each do |key, value|
      string << "class %s\n\tOPERATION = {}\n\tINSTRUCTION = {}\n\tF_VALUE = {}\n\tF_STR = {}\n" % key
      operations = ''
      f_values = ''

      indent = "\t"
      value.each_with_index do |code, opCode|

        if code.is_a?(Array) then
          str_initialized = false
          code.each_with_index do |realCode, f|
            next if realCode == nil

            operations << indent << ("OP_%s = %d\n" % [realCode, opCode])
            operations << indent << ("OPERATION['%s'] = OP_%s\n" % [realCode, realCode])
            operations << indent << ("INSTRUCTION[OP_%s] = '%s'\n" % [realCode, realCode])
            f_values << indent << ("F_%s = %d\n" % [realCode, f])
            f_values << indent << ("F_STR[OP_%s] = {}\n" % realCode) if not str_initialized
            str_initialized = true
            f_values << indent << ("F_VALUE['%s'] = F_%s\n" % [realCode, realCode])
            f_values << indent << ("F_STR[OP_%s][F_%s] = '%s'\n" % [realCode, realCode, realCode])

          end
        else
          operations << indent << ("OP_%s = %d\n" % [code, opCode])
          operations << indent << ("OPERATION['%s'] = OP_%s\n" % [code, code])
          operations << indent << ("INSTRUCTION[OP_%s] = '%s'\n" % [code, code])
        end
      end

      string << operations
      string << f_values
      string << "end\n"
    end
    string
  end

end