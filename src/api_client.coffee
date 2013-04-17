url               = require 'url'
config            = require 'config'
util              = require 'util'
request           = require 'request'
fs                = require 'fs'
{extend, each}    = require 'underscore'

class ApiClient
  @create: (name) ->
    endpoint_config = config.Endpoints[name]
    clazz = ApiClient
    clazz = @types[endpoint_config.type] if endpoint_config.type
    new clazz(endpoint_config)

  @types =
    'ApiClient': ApiClient

  @load: (cb, dirname = __dirname) ->
    fs.readdir dirname, (err, files) ->
      cb(err, null) if err && cb
      each files, (file) ->
        full_path = "#{dirname}/#{file}"
        require full_path
      cb(null, files) if cb


  constructor: (options) ->
    @host = options.host
    @port = options.port
    @options = options.options || {}
    if @options.protocol && @options.protocol == 'https'
      @port ||= 443
    else
      @port ||= 80
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
      #console.log "Making request: " + util.inspect(request_opts)
      request request_opts

module.exports = ApiClient
