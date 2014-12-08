SwaggerYard.configure do |config|
  config.reload                   = true
  config.swagger_version          = "1.2"
  config.api_version              = "1.0"
  config.swagger_spec_base_path   = "http://localhost:3000/swagger/api"
  config.api_base_path            = "http://localhost:3000/api"
  config.overwrite_path_parameter = true
  config.application_name         = "Dummy Test API"
  config.terms_of_service_url     = "https://github.com/thorsteneckel/swagger_yard"
  config.license                  = "Apache 2.0"
  config.license_url              = "http://www.apache.org/licenses/LICENSE-2.0.html"
end
