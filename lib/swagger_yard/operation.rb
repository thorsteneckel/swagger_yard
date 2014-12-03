module SwaggerYard
  class Operation
    attr_accessor :summary, :notes
    attr_reader :path, :http_method, :response_message, :response_type
    attr_reader :parameters, :model_names

    PARAMETER_LIST_REGEX = /\A\[(\w*)\]\s*(\w*)(\(required\))?\s*(.*)\n([.\s\S]*)\Z/

    # TODO: extract to operation builder?
    def self.from_yard_object(yard_object, api)
      new(api).tap do |operation|
        yard_object.tags.each do |tag|
          case tag.tag_name
          when "path"
            operation.add_path_params_and_method(tag)
          when "parameter"
            operation.add_parameter(tag)
          when "parameter_list"
            operation.add_parameter_list(tag)
          when "response_type"
            operation.add_response_type(Type.from_type_list(tag.types))
          when "response_message"
            operation.add_response_message(tag)
          when "summary"
            operation.summary = tag.text
          when "notes"
            operation.notes = tag.text.gsub("\n", "<br\>")
          end
        end

        operation.sort_parameters
      end
    end

    def initialize(api)
      @api = api
      @parameters = []
      @model_names = []
      @response_message = []
    end

    def nickname
      @path[1..-1].gsub(/[^a-zA-Z\d:]/, '-').squeeze("-") + http_method.downcase
    end

    def to_h
      {
        "httpMethod"        => http_method,
        "nickname"          => nickname,
        "type"              => "void",
        "produces"          => ["application/json", "application/xml"],
        "parameters"        => parameters.map(&:to_h),
        "summary"           => summary || @api.description,
        "notes"             => notes,
        "responseMessages"  => response_message
      }.tap do |h|
        h.merge!(response_type.to_h) if response_type
      end
    end

    ##
    # Example: [GET] /api/v2/ownerships.{format_type}
    # Example: [PUT] /api/v1/accounts/{account_id}.{format_type}
    def add_path_params_and_method(tag)
      @path = tag.text
      @http_method = tag.types.first

      parse_path_params(tag.text).each do |name|

        if name == 'format_type'
          append_format_parameter
        else
          @parameters << Parameter.from_path_param(name)
        end
      end
    end

    ##
    # Example: [Array]     status            Filter by status. (e.g. status[]=1&status[]=2&status[]=3)
    # Example: [Array]     status(required)  Filter by status. (e.g. status[]=1&status[]=2&status[]=3)
    # Example: [Array]     status(required, body)  Filter by status. (e.g. status[]=1&status[]=2&status[]=3)
    # Example: [Integer]   media[media_type_id]                          ID of the desired media type.
    def add_parameter(tag)
      parameter = Parameter.from_yard_tag(tag, self)

      add_parameter = true
      # Check for existing parameters to overwrite?
      if SwaggerYard.config.overwrite_path_parameter &&
          @parameters.any?

        @parameters.map! { |p|

          # Match only path parameter with same name
          if p.param_type == 'path' &&
             p.name       == parameter.name

            add_parameter        = false
            parameter.param_type = 'path'

            parameter
          else
            p
          end
        }
      end

      if add_parameter
        @parameters << parameter
      end
    end


    ##
    # Example: [String]    sort_order  Orders ownerships by fields. (e.g. sort_order=created_at)
    #          [List]      id
    #          [List]      begin_at
    #          [List]      end_at
    #          [List]      created_at
    def add_parameter_list(tag)
      # TODO: switch to using Parameter.from_yard_tag
      data_type, name, required, description, list_string = parse_parameter_list(tag)
      allowable_values = parse_list_values(list_string)

      @parameters << Parameter.new(name, Type.new(data_type.downcase), description, {
        required: required.present?,
        param_type: "query",
        allow_multiple: false,
        allowable_values: allowable_values
      })
    end

    def add_response_type(type)
      model_names << type.model_name
      @response_type = type
    end

    def add_response_message(tag)
      @response_message << {
        "code" => Integer(tag.name),
        "message" => tag.text,
        "responseModel" => Array.wrap(tag.types).first
      }.reject {|_,v| v.nil?}
    end

    def sort_parameters
      @parameters.sort_by! {|p| p.name}
    end

    def append_format_parameter
      @parameters << format_parameter
    end

    def ref?(data_type)
      @api.ref?(data_type)
    end

    private
    def parse_path_params(path)
      path.scan(/\{([^\}]+)\}/).flatten
    end

    def parse_parameter_list(tag)
      tag.text.match(PARAMETER_LIST_REGEX).captures
    end

    def parse_list_values(list_string)
      list_string.split("[List]").map(&:strip).reject { |string| string.empty? }
    end

    def format_parameter
      Parameter.new("format_type", Type.new("string"), "Response format either JSON or XML", {
        required: true,
        param_type: "path",
        allow_multiple: false,
        allowable_values: ["json", "xml"]
      })
    end
  end
end
