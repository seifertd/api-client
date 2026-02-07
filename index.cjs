'use strict';

var url = require('url');
var config = require('config');

const normalizePath = (base_path, path) => {
  let pathname = [base_path, path].filter(Boolean).join("/");
  if (!pathname.startsWith("/")) {
    pathname = `/${pathname}`;
  }
  return pathname.replaceAll(/\/\/+/g, '/');
};

class ApiClient {
  static types = {
    "ApiClient": ApiClient
  }
  static endpoints = {};
  static {
    try {
      this.endpoints = Object.assign({}, config.get('endpoints'));
    } catch (e) {
    }
  }

  static create(name) {
    const endpointConfig = ApiClient.endpoints[name];
    if (endpointConfig === null) {
      throw new Error(`ApiClient endpoint ${name} not configured`);
    }
    let clazz = ApiClient.types[endpointConfig.type] || ApiClient;
    return new clazz(endpointConfig);
  }

  static registerClass(clazzName, clazz) {
    ApiClient.types[clazzName] = clazz;
  }

  static registerConfig(name, config) {
    ApiClient.endpoints[name] = config;
  }

  static load(config) {
    ApiClient.endpoints = Object.assign({}, ApiClient.endpoints, config);
  }

  constructor(endpointConfig) {
    this.host = endpointConfig.host;
    this.port = endpointConfig.port;
    this.options = endpointConfig.options || {};
    if (this.options.protocol && this.options.protocol == 'https') {
      this.port = this.port || 443;
    } else {
      this.port = this.port || 80;
    }
  }
  url(path, query = {}) {
    return url.format(this.url_config(path, query));
  }
  url_config(path, query = {}) {
    let pathname = normalizePath(this.options.base_path, path);
    return {
      hostname: this.host,
      port: this.port,
      pathname,
      protocol: this.options.protocol || 'http',
      query
    };
  }
  async get(path, query = {}, headers = {}) {
    return this.request('GET', path, query, null, headers);
  }
  async post(path, query = {}, body = {}, headers = {}) {
    return this.request('POST', path, query, body, headers);
  }
  async request(method, path, query, body, headers) {
    return fetch(this.url(path, query), {
      method,
      headers,
      body
    });
  }
}

exports.ApiClient = ApiClient;
