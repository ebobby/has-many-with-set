module HasManyWithSet
  module Accessors
    def self.build_getter_method (instance_var_name)
      Proc.new { instance_variable_get(instance_var_name) }
    end

    def self.build_setter_method (instance_var_name)
      Proc.new { |elements| instance_variable_set(instance_var_name, elements) }
    end
  end
end
