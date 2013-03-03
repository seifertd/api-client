url           = require 'url'
config        = require 'config'
util          = require 'util'
request       = require 'request'
{extend}      = require 'underscore'

class ApiClient
  @create: (name) ->
    endpoint_config = config.Endpoints[name]
    clazz = ApiClient
    clazz = @types[endpoint_config.type] if endpoint_config.type
    new clazz(endpoint_config)

  @types =
    'ApiClient': ApiClient

  constructor: (options) ->
    @host = options.host
    @port = options.port
    @options = options.options || {}
    @request_options = options.request_options

  api_path: ->
    @options.base_path || "/"

  url_config: (params = {}) ->
    hostname: @host
    port: @port
    pathname: @api_path()
    protocol: @options.protocol || 'http'
    query: params

  url: (params = {}) ->
    url.format @url_config(params)

  get: (params, headers, cb = undefined) ->
    request_opts =
      uri: @url(params)
      headers: headers
      method: 'GET'

    extend(request_opts, @request_options) if @request_options?

    request_opts.callback = cb if cb

    if @options.username && @options.password
      request.auth(@options.username, @options.password).request(request_opts)
    else
      console.log "Making request: " + util.inspect(request_opts)
      request request_opts

module.exports = ApiClient
