import * as fs from 'node:fs';
import url from 'url';
import config from 'config';
import fetch from 'node-fetch';

export class ApiClient {
  static types = {
    "ApiClient": ApiClient
  }
  static endpoints = config.get('endpoints');

  static create(name) {
    const endpointConfig = ApiClient.endpoints[name];
    if (endpointConfig === null) {
      throw new Error(`ApiClient endpoint ${name} not configured`);
    }
    let clazz = ApiClient.types[endpointConfig.type];
    return new clazz(endpointConfig);
  }

  static register(clazzName, clazz) {
    ApiClient.types[clazzName] = clazz;
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
  url(query = {}) {
    return url.format(this.url_config(query));
  }
  url_config(query = {}) {
    return {
      hostname: this.host,
      port: this.port,
      pathname: this.options.base_path || '/',
      protocol: this.options.protocol || 'http',
      query
    };
  }
  async get(query, headers = {}) {
    return fetch(this.url(query), {
      method: 'GET',
      headers
    });
  }
}
