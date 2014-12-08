module SwaggerYard

  class Configuration

    attr_accessor :api_base_path,
                  :api_path,
                  :api_version,
                  :application_name,
                  :application_description,
                  :contact,
                  :enable,
                  :license,
                  :license_url,
                  :overwrite_path_parameter,
                  :receive_content_types,
                  :reload,
                  :response_content_types,
                  :swagger_spec_base_path,
                  :swagger_version,
                  :terms_of_service_url


    def initialize
      self.swagger_version          = "1.2"
      self.api_version              = "0.1"
      self.enable                   = false
      self.reload                   = true
      self.overwrite_path_parameter = false
      self.receive_content_types    = ["application/json", "application/xml"]
      self.response_content_types   = ["application/json", "application/xml"]
      self.application_name         = 'Ruby on Rails API via swagger_yard gem'
      self.application_description  = 'An API documented with the help of the swagger_yard gem'
      self.terms_of_service_url     = nil
      self.contact                  = nil
      self.license                  = nil
      self.license_url              = nil
    end
  end
end
