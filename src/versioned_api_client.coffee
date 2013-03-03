ApiClient = require './api_client'

class VersionedApiClient extends ApiClient

  ApiClient.types['VersionedApiClient'] = VersionedApiClient

  constructor: (options) ->
    super(options)

  api_path: ->
    path = super
    "#{path}/#{@options.version}"

module.exports = VersionedApiClient
