config      = require 'config'
expect      = require('chai').expect

ApiClient = require '../lib/api_client'
VersionedApiClient = require '../lib/versioned_api_client'

describe 'VersionedApiClient', ->
  beforeEach ->
    @endpoint = ApiClient.create('subclass_api')

  it 'has the right path', ->
    expect(@endpoint.api_path()).to.equal("/apibase/v1")

  it 'has the right url', ->
    expect(@endpoint.url()).to.equal("http://versioned.com:99/apibase/v1")
