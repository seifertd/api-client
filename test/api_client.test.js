import * as chai from 'chai';
const { expect } = chai;
import { ApiClient } from '../lib/api_client.js';
import config from 'config';
import http from 'http';

class Foo extends ApiClient {}

describe("ApiClient", _ => {
  describe("Registering custom classes", () => {
    let fooClient = null;
    let fooConfig = null;
    before( () => {
      ApiClient.registerClass('Foo', Foo);
      fooClient = ApiClient.create('foo');
      fooConfig = ApiClient.endpoints.foo;
    });
    it("has the right host", () => {
      expect(fooClient.host).to.equal(fooConfig.host);
    });
    it("has the right url", () => {
      expect(fooClient.url()).to.equal('http://foo.com:80/foobase');
    }); 
  });
  describe("Registering custom configuration", () => {
    let fooClient = null;
    let fooConfig = null;
    before( () => {
      ApiClient.registerClass('Foo', Foo);
      ApiClient.registerConfig('customfoo', {
        type: "Foo",
        host: "customfoo.com",
        options: {
          "base_path": "/customfoobase"
        }
      });
      fooClient = ApiClient.create('customfoo');
      fooConfig = ApiClient.endpoints.customfoo;
    });
    it("has the right host", () => {
      expect(fooClient.host).to.equal(fooConfig.host);
    });
    it("has the right url", () => {
      expect(fooClient.url()).to.equal('http://customfoo.com:80/customfoobase');
    }); 
  });
  describe('Built from client configuration', () => {
    before(() => {
      const custom = {
        bar: {
          type: "Foo",
          host: 'bar.com',
          options: {
            base_path: '/barbase'
          }
        },
        foo: {
          type: "Foo",
          host: 'overridefoo.com',
          options: {
            base_path: '/overridefoopath'
          }
        }
      };
      ApiClient.load(custom);
    });
    it("can create new instances", () => {
      const endpoint = ApiClient.create("bar");
      expect(endpoint.host).to.equal(ApiClient.endpoints.bar.host)
    });
    it("can create overridden instances", () => {
      const endpoint = ApiClient.create("foo");
      expect(endpoint.host).to.equal("overridefoo.com");
    });
  });
  describe("Endpoint with no basepath", () => {
    let endpoint = null;
    before(() => {
      endpoint = new ApiClient({
        host: 'test.com',
        port: 80
      });
    });
    it("normalizes null path", () => {
      expect(endpoint.url(null)).to.equal("http://test.com:80/")
      expect(endpoint.url(null, {foo: 'bar'})).to.equal("http://test.com:80/?foo=bar")
    });
    it("normalizes / path", () => {
      expect(endpoint.url("/")).to.equal("http://test.com:80/")
      expect(endpoint.url("/", {foo: 'bar'})).to.equal("http://test.com:80/?foo=bar")
    });
    it("normalizes non empty path", () => {
      expect(endpoint.url("more")).to.equal("http://test.com:80/more")
      expect(endpoint.url("/more", {foo: 'bar'})).to.equal("http://test.com:80/more?foo=bar")
    });
  });
  describe("Endpoint with basepath", () => {
    let endpoint = null;
    before(() => {
      endpoint = new ApiClient({
        host: 'test.com',
        port: 80,
        options: { base_path: "/foo" }
      });
    });
    it("normalizes null path", () => {
      expect(endpoint.url(null)).to.equal("http://test.com:80/foo")
      expect(endpoint.url(null, {foo: 'bar'})).to.equal("http://test.com:80/foo?foo=bar")
    });
    it("Normalizes non-null path", () => {
      expect(endpoint.url("stuff")).to.equal("http://test.com:80/foo/stuff")
      expect(endpoint.url("/stuff")).to.equal("http://test.com:80/foo/stuff")
    });
  });
  describe("Basic ApiClient", () => {
    let server = null;
    let client = null;
    let reqHdrs = null;
    let reqUrl = null;
    let reqMeth = null;
    before(() => {
      server = http.createServer((req, res) => {
        reqHdrs = req.headers;
        reqUrl = req.url;
        reqMeth = req.method;
        res.writeHead(200, { 'Content-Type': 'text/json' });
        res.end('{"sigma":"alpha"}');
      });
      server.listen(8888, 'localhost', () => {});
      ApiClient.registerConfig('localhost', {
        host: "localhost",
        port: "8888"
      });
      client = ApiClient.create('localhost');
    });
    after(() => {
      server.close(() => {});
    });
    it("Can make a get request", async () => {
      const response = await client.get("/", {foo: 'bar'}, {"Header1": "value1"});
      expect(response.status).to.equal(200);
      expect(client.url("/", {foo: "bar"})).to.include(reqUrl);
      expect(reqHdrs['header1']).to.equal("value1");
      expect(reqMeth).to.equal('GET');
      const resJson = await response.json();
      expect(resJson).to.eql({sigma: "alpha"});
    });
    it("Can make a post request", async () => {
      const response = await client.post("/", {foo: 'bar'}, "post body", {"Header1": "value1", "Content-Type": "text/plain"});
      expect(response.status).to.equal(200);
      expect(client.url("/", {foo: "bar"})).to.include(reqUrl);
      expect(reqHdrs['header1']).to.equal("value1");
      expect(reqMeth).to.equal('POST');
      const resJson = await response.json();
      expect(resJson).to.eql({sigma: "alpha"});
    });
  });
});
