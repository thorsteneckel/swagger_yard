module SwaggerYard
  class ApiDeclaration
    attr_accessor :description, :resource_path
    attr_reader :apis, :authorizations

    def initialize(resource_listing)
      @resource_listing = resource_listing

      @apis   = {}
      @authorizations = {}
    end

    def valid?
      !@resource_path.nil?
    end

    def add_yard_objects(yard_objects)
      yard_objects.each do |yard_object|
        add_yard_object(yard_object)
      end
      self
    end

    def add_yard_object(yard_object)
      case yard_object.type
      when :class
        add_listing_info(ListingInfo.new(yard_object))
        add_authorizations_to_resource_listing(yard_object)
      when :method
        add_api(yard_object)
      end
    end

    def add_listing_info(listing_info)
      @description = listing_info.description
      @resource_path = listing_info.resource_path

      # we only have api_key auth, the value for now is always empty array
      @authorizations = Hash[listing_info.authorizations.uniq.map {|k| [k, []]}]
    end

    def add_api(yard_object)
      path = Api.path_from_yard_object(yard_object)

      return if path.nil?

      api = (apis[path] ||= Api.from_yard_object(yard_object, self))
      api.add_operation(yard_object)
    end

    # HACK, requires knowledge of resource_listing
    def add_authorizations_to_resource_listing(yard_object)
      yard_object.tags.select {|t| t.tag_name == "authorization"}.each do |t|
        @resource_listing.authorizations << Authorization.from_yard_object(t)
      end
    end

    def resource_name
      @resource_path
    end

    def models
      (api_models + property_models).uniq
    end

    def ref?(name)
      @resource_listing.models.map(&:id).include?(name)
    end

    def to_h
      {
        "apiVersion"     => SwaggerYard.config.api_version,
        "swaggerVersion" => SwaggerYard.config.swagger_version,
        "basePath"       => SwaggerYard.config.api_base_path,
        "resourcePath"   => resource_path,
        "apis"           => apis.values.map(&:to_h),
        "models"         => Hash[models.map {|m| [m.id, m.to_h]}],
        "authorizations" => authorizations
      }
    end

    def listing_hash
      {
        "path"        => resource_path,
        "description" => description
      }
    end

    private
    def model_names_from_apis
      apis.values.map(&:model_names).flatten.uniq
    end

    # models selected by the names of models referenced in APIs
    def api_models
      @resource_listing.models.select {|m| model_names_from_apis.include?(m.id)}
    end

    def model_names_from_model_properties
      api_models.map(&:properties_model_names).flatten.uniq
    end

    # models selected by names used in properties in models used in APIs
    def property_models
      @resource_listing.models.select {|m| model_names_from_model_properties.include?(m.id)}
    end
  end
end
