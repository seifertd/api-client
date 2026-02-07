api-client
==========

node.js fetch wrapper and api endpoint configuration management

Why?
----

Needed a driver for fetch that clearly separated configuration
of web service API endpoints from the code that consumed them.

Installation
------------

    npm install api-client

TLDR
----
```javascript
import { ApiClient } from 'api-client';
const client = ApiClient.create("dseifert");
const r = await client.get("bookmarks.html")
console.log("RESPONSE: ", r);
```

`client.get(path, query, headers)`
  * path: relative path of the request, is appended to base\_path
    if you have a base\_path in your endpoint configuration.
  * query: query string args as a Javascript object
  * headers: request headers as a Javascript object

If you need to use Basic auth, add the appropriate request
header.

Usage
-----

api-client manages configuration and creation of a set of named api
endpoints.  Endpoint configuration can be achieved in one of three ways:

  1.  The library can load a configuration using the *node-config* module.
      (See https://github.com/node-config/node-config)
  1.  The configuration can be supplied explicitly to the library by
      clients
  1.  Configuration can be added piecemeal by registering endpoint
      classes and configuration by calling functions.

In the first case, the configuration should define a single attribute
'endpoints', pointing at an object. The object in turn contains any number
of endpoint configuration objects as attributes.

```json
{
  "endpoints": {
    "twitter": {
      "type": "ApiClient",
      "host": "api.twitter.com",
      "options": {
        "protocol": "https"
      }
    },
    "other_api": {
      "host": "other.com"
      ...
    }
  }
}
```

The above configuration object defines configuration of two named 
endpoints, 'twitter' and 'other\_api'.  The configurations can be
referred to by name when creating instances of ApiClient for sending
requests to the web service api.  The configuration may specify a
'type' attribute, whose value is the name of a registered or 
pre-configured api client object.

Configuration
-------------

Each endpoint configuration object has the following layout:

```json
"host": "some.host.com"     # The only required attribute
"port": 232                 # Defaults to 80 or 443, depending on the
                            #   options.protocol attribute
"type": "StringClassName"   # Defaults to 'ApiClient'
"options": {
  "protocol": "http|https", # Either 'http' or 'https', defaults to 'http'
  "base_path": "/apibase",  # The base of all url paths for the service, defaults to '/'
}
```

The url formed by the api-client will therefore be:

"#{options.protocol}://#{host}:#{port}#{base\_path}"

### Using the default configuration

```javascript
import { ApiClient } from 'api-client';
const client = ApiClient.create("dseifert");
const r = await client.get('/', {});
console.log("RESPONSE: ", r);
```

### Client supplied configuration

```javascript
import { ApiClient } from 'api-client';
const myConfig = {
  foo_client: {
    host: 'foo.com'
  }
};
ApiClient.load(myConfig);
foo_client = ApiClient.create('foo_client')
foo_client.get({...})
```

### Registering client created ApiClient subclasses

```javascript
import { ApiClient } from 'api-client';

class FooClient extends ApiClient {
  test() {
    console.log("Foo request: " + self.url());
  }
}

ApiClient.registerClass('FooClient', FooClient);
ApiClient.registerConfig('fooclient', {
  host: 'foo.com',
  type: 'FooClient',
  options: {
    base_path: '/fooapi'
  }
});
fc = ApiClient.create('fooclient')
fc.test()
```
License
-------

MIT Licensed

Copyright (c) 2013 Douglas A. Seifert

