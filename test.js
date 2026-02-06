import { ApiClient } from './lib/api_client.js';

const client = ApiClient.create("dseifert");

const r = await client.get({});

console.log("RESPONSE: ", r);
