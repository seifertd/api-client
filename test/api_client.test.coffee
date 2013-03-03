config      = require 'config'
util        = require 'util'
expect      = require('chai').expect

ApiClient   = require '../lib/api_client'

describe 'ApiClient', ->
  describe 'built from configuration', ->
    beforeEach ->
      @endpoint_config = config.Endpoints.test_api
      @endpoint = new ApiClient(@endpoint_config)

    it "is configured correctly", ->
      expect(@endpoint.host).to.equal(@endpoint_config.host)
      expect(@endpoint.port).to.equal(@endpoint_config.port)
      expect(@endpoint.options).to.equal(@endpoint_config.options)

    it "forms the path correctly", ->
      expect(@endpoint.api_path()).to.equal("/apibase")

    it "forms the url correctly", ->
      expect(@endpoint.url()).to.equal("http://test.com:80/apibase")

    it "forms the url with params correctly", ->
      expect(@endpoint.url(foo: 'bar')).to.equal("http://test.com:80/apibase?foo=bar")

    it "forms the url with params escaped correctly", ->
      expect(@endpoint.url(foo: 'bar zoom')).to.equal("http://test.com:80/apibase?foo=bar%20zoom")

    it "can be created by name", ->
      test_endpoint = ApiClient.create('test_api')
      expect(@endpoint.host).to.equal(test_endpoint.host)
      expect(@endpoint.port).to.equal(test_endpoint.port)
      expect(@endpoint.options).to.equal(test_endpoint.options)

  describe 'with no base path option', ->
    beforeEach ->
      @endpoint_config =
        host: 'test.com'
        port: 80
      @endpoint = new ApiClient(@endpoint_config)

    it "has the default api path", ->
      expect(@endpoint.api_path()).to.equal("/")
