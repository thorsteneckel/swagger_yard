# @resource Pet
# @resource_path /pets
#
# This document describes the API for interacting with Pet resources
#
# @authorize_with header_x_application_api_key
#
class PetsController < ApplicationController
  # return a list of Pets
  # @path [GET] /pets.{format_type}
  # @receive_content_type application/json
  # @response_content_type application/json
  # @response_type [Array<Pet>]
  # @parameter client_name(required) [string] The name of the client using the API
  def index
  end

  # return a Pet
  # @path [GET] /pets/{id}.{format_type}
  # @parameter id [integer] The ID for the Pet
  # @parameter price [float] The price of the Pet
  # @parameter weight [double] Just a test double parameter
  # @parameter unixtimestamp [long] Just a test long parameter
  # @parameter size [byte] Just a test byte parameter
  # @parameter birthday [date] The birthday of the pet
  # @parameter added [datetime] The date and time the Pet was added to the store
  # @response_type [Pet]
  # @response_content_type application/xml
  # @response_content_type application/json
  # @response_content_type application/json
  # @response_message [EmptyPet] 404 Pet not found
  # @response_message 400 Invalid ID supplied
  def show
  end

  # create a Pet
  # @path [POST] /pets
  # @summary create a Pet (overwritten)
  # @notes First line of the note.
  #        Second line of the note.
  # @parameter pet(required,body) [Pet] The pet object
  def create
  end

  # def update
  # end

  # def destroy
  # end
end
