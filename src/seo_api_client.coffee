ApiClient = require './api_client'
VersionedApiClient = require './versioned_api_client'

class SeoApiClient extends VersionedApiClient

  ApiClient.types['SeoApiClient'] = SeoApiClient

  api_path: ->
    path = super
    path = "#{path}/#{@endpoint_path}"
    if @seo_geo_slug?
      path = "#{path}/#{@channel}/#{@seo_geo_slug}"
      path += "/#{@category}" if @category?
    else
      path = "#{path}/#{@latitude}/#{@longitude}"

  pages: (options, headers, cb = undefined) ->
    query = {}
    @endpoint_path = 'pages'
    if options.seo_geo_slug?
      @channel = options.channel || 'local'
      @seo_geo_slug = options.seo_geo_slug
      @category = options.category
    else
      @latitude = options.lat
      @longitude = options.lng
      query.category = options.category if options.category

    @get(query, headers, cb)

module.exports = SeoApiClient
