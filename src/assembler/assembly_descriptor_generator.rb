require 'yaml'

class AssemblyDescriptorGenerator
  def initialize(file)
    @file = file
  end

  def generate
    data = YAML.load_file(@file)
    string = ''
    data.each do |key, value|
      string << "class %s\n\tOPERATION = {}\n\tF_VALUE = {}\n" % key
      operations = ''
      f_values = ''

      indent = "\t"
      value.each_with_index do |code, opCode|

        if code.is_a?(Array) then
          code.each_with_index do |realCode, f|
            next if realCode == nil

            operations << indent << ("OP_%s = %d\n" % [realCode, opCode])
            operations  << indent << ("OPERATION['%s'] = OP_%s\n" % [realCode, realCode])
            f_values << indent << ("F_%s = %d\n" % [realCode, f])
            f_values  << indent << ("F_VALUE['%s'] = F_%s\n" % [realCode, realCode])

          end
        else
          operations << indent << ("OP_%s = %d\n" % [code, opCode])
          operations  << indent << ("OPERATION['%s'] = OP_%s\n" % [code, code])
        end
      end

      string << operations
      string << f_values
      string << "end\n"
    end
    string
  end

end