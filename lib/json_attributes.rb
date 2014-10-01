# Copyright (c) 2014 Public Library of Science
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Allow adding attributes that can be read and written as a JSON style hash

module JsonAttributes

  def json_attribute(*names)
    if ! defined? json_attribute_fields
      cattr_accessor(:json_attribute_fields) { [] }

      define_method :reload do
        json_attribute_fields.each do
          |name| remove_instance_variable( "@#{name}") if instance_variable_defined?("@#{name}")
        end
        super()
      end
    end

    self.json_attribute_fields += names

    # Define accessors for each name

    names.each do |name|
      var_name = "@#{name}"

      # read accessor
      define_method( "#{name}" ) do
        # Check if we have a cached copy
        if  instance_variable_defined?(var_name)
          instance_variable_get(var_name)

        else
          raw = read_attribute(name)
          json = raw && MultiJson.load(raw)
          instance_variable_set(var_name, json)
        end
      end

      # write accessor
      define_method( "#{name}=" ) do |value|
        remove_instance_variable(var_name) if instance_variable_defined?(var_name)
        write_attribute(name, value && MultiJson.dump(value) )
      end

    end # names.each

  end

  alias json_attributes json_attribute

end
