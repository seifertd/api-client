util        = require 'util'
expect      = require('chai').expect
bond        = require 'bondjs'

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

  describe 'with request_options', ->
    beforeEach ->
      class Foo extends ApiClient
        test: (params, headers, cb) ->
          @get(params, headers, cb)
      @foo_config =
        host: 'foo.com'
        options:
          base_path: '/foobase'
        request_options:
          proxy: 'http://localhost:8888'
      ApiClient.register('foo', Foo, 'Foo', @foo_config)
      @endpoint = ApiClient.create('foo')

    it 'has the right host', ->
      expect(@endpoint.host).to.equal(@foo_config.host)

    it 'has the right url', ->
      expect(@endpoint.url()).to.equal("http://foo.com:80/foobase")

    it 'can be called', (done) ->
      bond(@endpoint, 'request').to (args) ->
        expect(args.uri).to.equal('http://foo.com:80/foobase?foo=bar')
        expect(args.headers.header1).to.equal('HEADER1')
        expect(args.proxy).to.equal("http://localhost:8888")
        done()
      @endpoint.get({foo: 'bar'}, {header1: 'HEADER1'})

    it "has the right request options", ->
      expect(@endpoint.request_options).to.deep.equal({timeout: 2000, proxy: 'http://localhost:8888'})

    it "doesn't blow away the default request options", ->
      expect(ApiClient.default_request_options).to.deep.equal({timeout: 2000})

  describe 'built from client configuration', ->
    beforeEach ->
      @config =
        endpoints:
          foo_api:
            host: 'foo.com'
            options:
              base_path: '/foobase'
      ApiClient.config = null
      ApiClient.load @config
      @endpoint = ApiClient.create('foo_api')

    it "has the right host", ->
      expect(@endpoint.host).to.equal(@config.endpoints.foo_api.host)

    it "has the right port", ->
      expect(@endpoint.port).to.equal(80)

    it "has the right url", ->
      expect(@endpoint.url()).to.equal("http://foo.com:80/foobase")

    it "doesn't overwrite config if loaded more than once", ->
      ApiClient.load {endpoints: {}}
      expect((k for own k of ApiClient.config.endpoints).length).to.equal(1)

  describe 'built from default configuration', ->
    beforeEach ->
      ApiClient.config = null
      ApiClient.load null
      @endpoint_config = ApiClient.config.endpoints.test_api
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

    describe "with stubs", ->
      describe "and a callback", ->
        it "can stub errors", (done) ->
          test_endpoint = ApiClient.create('test_api')
          test_endpoint.stub_request(/.*/, {error: true}, null, null)
          test_endpoint.get {}, null, (err, response, body) ->
            expect(err).to.not.be_null
            done()
        it "can stub successes", (done) ->
          test_endpoint = ApiClient.create('test_api')
          test_endpoint.stub_request(/.*/, null, null, 'body')
          test_endpoint.get {}, null, (err, response, body) ->
            expect(err).to.be_null
            expect(body).to.equal 'body'
            done()
      describe "and no callback", ->
        it "can stub errors", (done) ->
          test_endpoint = ApiClient.create('test_api')
          test_endpoint.stub_request(/.*/, {error: true}, null, null)
          request = test_endpoint.get {}, null
          request.on 'error', (err) ->
            expect(err).to.not.be_null
            done()
        it "can stub successes", (done) ->
          test_endpoint = ApiClient.create('test_api')
          test_endpoint.stub_request(/.*/, null, null, 'body')
          request = test_endpoint.get {}, null
          request.on 'complete', (response, body) ->
            expect(body).to.equal 'body'
            done()

  describe 'with no base path option', ->
    beforeEach ->
      @endpoint_config =
        host: 'test.com'
        port: 80
      @endpoint = new ApiClient(@endpoint_config)

    it "has the default api path", ->
      expect(@endpoint.api_path()).to.equal("/")

    it "builds the url correctly", (done) ->
      bond(@endpoint, 'request').to (args) ->
        expect(args.uri).to.equal('http://test.com:80/?foo=bar')
        expect(args.headers.header1).to.equal('HEADER1')
        done()
      @endpoint.get({foo: 'bar'}, {header1: 'HEADER1'})

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
