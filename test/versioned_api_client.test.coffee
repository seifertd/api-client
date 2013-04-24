config      = require 'config'
expect      = require('chai').expect
util = require('util')

ApiClient = require '../lib/api_client'
VersionedApiClient = require '../lib/versioned_api_client'

describe 'VersionedApiClient', ->
  beforeEach (done) ->
    @endpoint = null
    ApiClient.load null, (err, files) =>
      @endpoint = ApiClient.create('subclass_api')
      done(err)

  it 'has the right path', ->
    expect(@endpoint.api_path()).to.equal("/apibase/v1")

  it 'has the right url', ->
    expect(@endpoint.url()).to.equal("http://versioned.com:99/apibase/v1")
