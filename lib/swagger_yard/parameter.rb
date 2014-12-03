module SwaggerYard
  class Parameter
    attr_accessor :name, :description, :param_type
    attr_reader :required, :allow_multiple, :allowable_values

    def self.from_yard_tag(tag, operation)
      description = tag.text
      name, options_string = tag.name.split(/[\(\)]/)
      type = Type.from_type_list(tag.types)

      options = {}

      operation.model_names << type.name if type.ref?

      unless options_string.nil?
        options_string.split(',').map(&:strip).tap do |arr|
          options[:required] = !arr.delete('required').nil?
          options[:allow_multiple] = !arr.delete('multiple').nil?
          options[:param_type] = arr.last
        end
      end

      new(name, type, description, options)
    end

    # TODO: support more variation in scope types
    def self.from_path_param(name)
      new(name, Type.new("string"), "Scope response to #{name}", {
        required: true,
        allow_multiple: false,
        param_type: "path"
      })
    end

    def initialize(name, type, description, options={})
      @name, @type, @description = name, type, description

      @required = options[:required] || false
      @param_type = options[:param_type] || 'query'
      @allow_multiple = options[:allow_multiple] || false
      @allowable_values = options[:allowable_values] || []
    end

    def type
      @type.name
    end

    def allowable_values_hash
      return nil if allowable_values.empty?

      allowable_values
    end

    def to_h
      {
        "paramType"     => param_type,
        "name"          => name,
        "description"   => description,
        "required"      => required,
        "allowMultiple" => allow_multiple.present?,
        "enum"          => allowable_values_hash,
      }.merge(@type.to_h).reject {|k,v| v.nil?}
    end
  end
end