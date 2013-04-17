api_client
==========

API client and configuration management for node.js

Why?
----

Needed a driver for the _request_ library that clearly separated configuration
of API endpoints from the code that consumed them.



Installation
------------

    npm install api_client

Usage
-----

Given a working directory with the following directory and file:

config/development.coffee

(See https://github.com/lorenwest/node-config for other formats
supported for config files)

And contents of the file:

```coffeescript
module.exports =
  Endpoints:
    twitter:
      type: 'TwitterClient'
      host: 'api.twitter.com'
      options:
        protocol: 'https'
```

We can do the following

```coffeescript
ApiClient = require 'api_client'

ApiClient.load (errs, files) ->
  console.log "Loaded API Client"

  var twitter = ApiClient.create('twitter');
  
  twitter.user_info(1, 'TwitterAPI', {include_entities: true}, (err, response, body) ->
    console.log "Got Twitter JSON data: " + body
```

License
-------

MIT Licensed

Copyright (c) 2013 Douglas A. Seifert

