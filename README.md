api-client
==========

node.js _request_ library wrapper and configuration management

Why?
----

Needed a driver for the _request_ library that clearly separated configuration
of web service API endpoints from the code that consumed them.



Installation
------------

    npm install api-client

Usage
-----

api-client manages configuration and creation of a set of named api
endpoints.  Endpoint configuration can be achieved in one of three ways:

  1.  The configuration can be supplied explicitly to the library by
      clients
  1.  The library can load a configuration using the *node_config*
      (See https://github.com/lorenwest/node-config) module.
  1.  Configuration can be added piecemeal by registering endpoint
      objects and corresponding configuration by calling a function

In the first two cases, the api-client library expects the config object
to have a single attribute, 'Endpoints', pointing at a object.  The object
in turn contains any number endpoint configuration objects as attributes:

```coffeescript
Endpoints:
  twitter:
    type: 'TwitterClient'
    host: 'api.twitter.com'
    options:
      protocol: 'https'
  other_api:
    host: 'other.com'
```

The above configuration object defines configuration of two named 
endpoints, 'twitter' and 'other_api'.  The configurations can be
referred to by name when creating instances of ApiClient for sending
requests to the web service api.  The configuration may specify a
'type' attribute, whose value is the name of a registered or 
pre-configured api client object.

### Using the default configuration

```coffeescript
ApiClient = require 'api_client'

ApiClient.load null, (err, config) ->
  console.log "Loaded API Client"

  # Create an instance of TwitterClient.
  twitter = ApiClient.create 'twitter'
  
  twitter.user_info(1, 'TwitterAPI', {include_entities: true}, (err, response, body) ->
    console.log "Got Twitter JSON data: " + body
```

### Client supplied configuration

```coffeescript
ApiClient = require 'api_client'
my_config =
  Endpoints:
    foo_client:
      host: 'foo.com'

ApiClient.load my_config, (err, config) ->
  console.log "Loaded API Client"

  foo_client = ApiClient.create('foo_client')

  foo_client.get({...})
```

### Registering client created ApiClient subclasses

```coffeescript
ApiClient = require 'api_client'

class FooClient extends ApiClient
  test: ->
    console.log "Foo request: " + @url()

ApiClient.register('foo', FooClient, 'FooClient', {
  host: 'foo.com',
  type: 'FooClient',
  options:
    base_path: '/fooapi'
})

console.log "Registered FooClient, config = " + util.inspect(ApiClient.config)

fc = ApiClient.create('foo')

fc.test()
```

License
-------

MIT Licensed

Copyright (c) 2013 Douglas A. Seifert

