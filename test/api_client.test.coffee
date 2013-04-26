util        = require 'util'
expect      = require('chai').expect

ApiClient   = require '../lib/api_client'

describe 'ApiClient', ->
  describe 'configured by registration', ->
    beforeEach ->
      class Foo extends ApiClient
      @foo_config =
        host: 'foo.com'
        options:
          base_path: '/foobase'
      ApiClient.register('foo', Foo, 'Foo', @foo_config)

    it 'has the right host', ->
      expect(ApiClient.create('foo').host).to.equal(@foo_config.host)

    it 'has the right url', ->
      expect(ApiClient.create('foo').url()).to.equal("http://foo.com:80/foobase")

  describe 'built from client configuration', ->
    beforeEach (done) ->
      @config =
        endpoints:
          foo_api:
            host: 'foo.com'
            options:
              base_path: '/foobase'
      ApiClient.load @config, (err, config) =>
        @api_config = config
        @endpoint = ApiClient.create('foo_api')
        done(err)

    it "gives back client config", ->
      expect(@config).to.equal(@api_config)

    it "has the right host", ->
      expect(@endpoint.host).to.equal(@config.endpoints.foo_api.host)

    it "has the right port", ->
      expect(@endpoint.port).to.equal(80)

    it "has the right url", ->
      expect(@endpoint.url()).to.equal("http://foo.com:80/foobase")

  describe 'built from default configuration', ->
    beforeEach (done) ->
      ApiClient.load null, (err, config) =>
        @endpoint_config = config.endpoints.test_api
        @endpoint = new ApiClient(@endpoint_config)
        done(err)

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

  ###
  # WTF? describe.skip does not work????
  describe.skip 'to a non existent host', ->
    beforeEach ->
      @endpoint_config =
        host: '127.0.0.5'
        port: 80
      @endpoint = new ApiClient(@endpoint_config)

    it "times out with an error", (done) ->
      @endpoint.get {}, {}, (error, response, body) ->
        expect(error).to.not.be(null)
        done()
  ###
