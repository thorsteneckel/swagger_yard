module SwaggerYard
  class Configuration
    attr_accessor :swagger_spec_base_path, :api_base_path, :api_path
    attr_accessor :swagger_version, :api_version
    attr_accessor :enable, :reload, :overwrite_path_parameter

    def initialize
      self.swagger_version          = "1.1"
      self.api_version              = "0.1"
      self.enable                   = false
      self.reload                   = true
      self.overwrite_path_parameter = false
    end
  end
end