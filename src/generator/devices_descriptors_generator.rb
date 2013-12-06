require 'yaml'

class DevicesDescriptorGenerator < AbstractGenerator

  def generate_class(class_name, devices)
    string = ''
    print "Generating class %s\n" % class_name
    string << "class %s\n" % class_name
    string << send('generate_%s' % class_name.downcase, devices)
    string << "end\n"
    print "Done class %s\n" %class_name
    string
  end

  def generate_devices(descriptors)
    string = ''
    descriptors.each do |name, attributes|
      print "Generating device %s\n" % name
      string << INDENT << 'class ' << name << "\n"
      string << INDENT<<INDENT << "BLOCK=%d\n" % attributes['Block']
      string << INDENT<<INDENT << "READ=%s\n" % (attributes['Read'] ? 'true': 'false')
      string << INDENT<<INDENT << "WRITE=%s\n" % (attributes['Write'] ? 'true': 'false')

      string << INDENT<<INDENT << 'def initialize('
      is_reading = attributes['Read'] == true
      is_writing = attributes['Write'] == true
      string << generate_initialize(is_reading, is_writing)

      string << generate_reader(attributes) if is_reading
      string << generate_writer(attributes) if is_writing


      string << INDENT << "end\n"
    end
    string
  end

  def generate_reader(attributes)
    string = ''
    string << INDENT * 2 << "def read(mu, address)\n"
    if attributes['Type'] == 'character'
      string << INDENT * 3 << "bytes = Limits::BYTES_IN_WORD\n"
      string << INDENT * 3 << "buf = @read_stream.read(BLOCK * 5)\n"
      string << INDENT * 3 << "buf = buf.ljust(BLOCK * 5)\n"
      string << INDENT * 3 << "BLOCK.times do |i|\n"
      string << INDENT * 4 << "mu.memory[address + i].store_string(buf.byteslice(i * bytes, bytes))\n"
      string << INDENT * 3 << "end\n"
    else
      string << '# TODO Read binary' + "\n"
    end

    string << INDENT * 2 << "end\n"
  end

  def generate_writer(attributes)
    string = ''
    string << INDENT * 2 << "def write(mu, address)\n"
    if attributes['Type'] == 'character'
      string << INDENT * 3<< "BLOCK.times do |i|\n"
      string << INDENT * 4 << "word = mu.fetch(address + i)\n"
      string << INDENT * 4 << "@write_stream << word.string\n"
      string << INDENT * 3 << "end\n"
      string << INDENT * 3 << "@write_stream << \"%s\"\n" % attributes['EndLine']

    else
      string << '# TODO write binary' + "\n"
    end

    string << INDENT * 2 << "end\n"
  end

  def generate_initialize(is_reading, is_writing)
    string = ''
    string << 'read_stream' if is_reading
    string << ', ' if is_reading and is_writing
    string << 'write_stream' if is_writing
    string << ")\n"

    string << INDENT << INDENT << INDENT << "@read_stream = read_stream\n" if is_reading
    string << INDENT << INDENT << INDENT << "@write_stream = write_stream\n" if is_writing

    string << INDENT << INDENT << "end\n"
  end

  def generate_ports(ports)
    string = INDENT + "PORTS = []\n"
    ports.each do |index, className|
      string << INDENT << "PORTS[%d] = :%s\n" % [index, className]
    end
    string
  end
end

