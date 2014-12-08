module SwaggerYard
  class Type
    def self.from_type_list(types)
      parts = types.first.split(/[<>]/)
      new(parts.last, parts.grep(/array/i).any?)
    end

    attr_reader :name, :array

    def initialize(name, array=false)
      @name, @array = name, array
    end

    # TODO: have this look at resource listing?
    def ref?
      !['integer', 'long', 'float', 'double', 'string', 'byte', 'boolean', 'date', 'datetime'].include? name.downcase
    end

    def model_name
      ref? ? name : nil
    end

    alias :array? :array

    def to_h
      tag_type = ref? ? "$ref" : "type"
      tag_name = ref? ? name   : name.downcase

      hash = {}

      if array?
        hash = {
          "type"  => "array",
          "items" => {
            tag_type => tag_name
          }
        }
      else
        if tag_name === 'integer'
          hash["type"]   = 'integer'
          hash["format"] = 'int32'
        elsif tag_name === 'long'
          hash["type"]   = 'integer'
          hash["format"] = 'int64'
        elsif tag_name === 'float'
          hash["type"]   = 'number'
          hash["format"] = 'float'
        elsif tag_name === 'double'
          hash["type"]   = 'number'
          hash["format"] = 'double'
        elsif tag_name === 'byte'
          hash["type"]   = 'string'
          hash["format"] = 'byte'
        elsif tag_name === 'date'
          hash["type"]   = 'string'
          hash["format"] = 'date'
        elsif tag_name === 'datetime'
          hash["type"]   = 'string'
          hash["format"] = 'date-time'
        # string and boolean and refs
        else
          hash[tag_type] = tag_name
        end
      end

      hash
    end
  end
end
