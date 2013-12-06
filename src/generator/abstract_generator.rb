class AbstractGenerator
  INDENT = "\t"
  attr_reader :file
  def initialize(file)
    @file = file
  end
  def generate
    data = YAML.load_file(@file)
    string = ''
    data.each do |class_name, constants_list|
      string << generate_class(class_name, constants_list)
    end
    string
  end
end