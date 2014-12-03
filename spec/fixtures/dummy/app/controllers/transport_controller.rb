# @resource Transport
# @resource_path /transports
#
# This document describes the API for interacting with Transport resources
#
# @authorize_with header_x_application_api_key
#
class TransportsController < ApplicationController
  # return a list of Transports
  # @path [GET] /transports.{format_type}
  # @parameter_list [String]    sort_order        Orders response by fields. (e.g. sort_order=created_at).
  #                 [List]      id
  #                 [List]      begin_at
  #                 [List]      end_at
  #                 [List]      created_at
  # @response_type [Array<Transport>]
  def index
  end
end
