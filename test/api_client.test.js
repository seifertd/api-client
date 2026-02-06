import * as chai from 'chai';
import spies from 'chai-spies';
chai.use(spies);
const { expect } = chai;
import { ApiClient } from '../lib/api_client.js';
import config from 'config';

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
    it("has the default api path of /", () => {
      expect(endpoint.url()).to.equal("http://test.com:80/")
      expect(endpoint.url({foo: 'bar'})).to.equal("http://test.com:80/?foo=bar")
    });
  });
});
