require 'swagger_yard'
require 'net/http'

namespace :swagger do
  desc "Generate and upload swagger json"
  task :deploy => :environment do |t, args|
    resource_listing = SwaggerYard::ResourceListing.new(
      Rails.root+'app/controllers/**/*.rb',
      Rails.root+'app/models/**/*.rb'
    )

    app_name = ENV["APP_NAME"] || "api"

    SwaggerYard.config.swagger_spec_base_path = "/swagger/#{app_name}"
    SwaggerYard.config.api_base_path = "/api"

    json = {"resource_listing" => resource_listing.to_h}.merge(Hash[
      resource_listing.controllers.map do |path, declaration|
        [path, declaration.to_h]
      end
    ]).to_json

    # File.open('/tmp/swagger.json', 'w') {|f| f.write(json)}
  
    uri = URI(args[:swagger_service_url] || ENV["SWAGGER_SERVICE_URL"])

    http = Net::HTTP.new(uri.hostname)
    http.request_post(uri.path, json)
  end
end
