# Allow adding attributes that can be read and written as a JSON style hash

module JsonAttributes

  def json_attribute(*names)

    if ! defined? @@json_attributes
      @@json_attributes = []

      define_method :reload do
        @@json_attributes.each do
          |name| remove_instance_variable( "@#{name}") if instance_variable_defined?("@#{name}")
        end
        super()
      end
    end

    @@json_attributes += names

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