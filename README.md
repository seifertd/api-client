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

```coffeescript
ApiClient = require 'api_client'

ApiClient.load (errs, files) ->
  console.log "Loaded API Client"

  # Create an instance of TwitterClient.
  var twitter = ApiClient.create 'twitter'
  
  twitter.user_info(1, 'TwitterAPI', {include_entities: true}, (err, response, body) ->
    console.log "Got Twitter JSON data: " + body
```

License
-------

MIT Licensed

Copyright (c) 2013 Douglas A. Seifert

