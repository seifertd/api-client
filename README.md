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
  "username": "user",       # Defaults to null, use to configure HTTP basic auth
  "password": "pass"        # Defaults to null, use to configure HTTP basic auth
}
```

The url formed by the api-client will therefore be:

"#{options.protocol}://#{host}:#{port}#{base\_path}"

### Using the default configuration

```javascript
import { ApiClient } from './lib/api_client.js';
const client = ApiClient.create("dseifert");
const r = await client.get({});
console.log("RESPONSE: ", r);
```

### Client supplied configuration

```javascript
import { ApiClient } from './lib/api_client.js';
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
import { ApiClient } from './lib/api_client.js';

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

Stubbing and Testing
--------------------
TBD
The api-client library is written to support testing against it by stubbing
requests by url regex.  Stubs can be set using the configuration mechanism
or set explicitly on an instance of the ApiClient class.

Via configuration:

```coffeescript
endpoints:
  myclient:
    type: 'ApiClient'
    host: 'somehost.com'
    options:
      base_path: '/foo'
    stubs: [
      [ /.*/, null, null, 'stub body' ]
    ] 
```

or programatically:

```coffeescript
myClient = ApiClient.create 'myclient'
myClient.stub_request [ /.*/, null, null, 'stub body' ]
```

The stub definition consists of an array of four objects:

  1. A regex that will test the url.  If the test is true, this stub will be used
  1. An error object to return if the stub is used
  1. A response object to return if the stub is used
  1. A body object to return if the stub is used.

In either of the above cases, any @get call against the client would result
in 'stub body' being returned as the body because the regex would match any
url.

The stub body can be either a static string, or an object with a 'file' attribute.
In the latter case, the file attribute is the path name of a file whose contents
are used as the stub body.

License
-------

MIT Licensed

Copyright (c) 2013-14 Douglas A. Seifert

