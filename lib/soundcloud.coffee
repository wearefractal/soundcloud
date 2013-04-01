cookie = require 'cookie'
request = require 'superagent'

apiKey = null

getParam = (param) ->
  url = window.location.hash
  re = new RegExp "##{param}=([^&]+)(&|$)"
  match = url.match re
  return unless match? and match[1]?
  return match[1]

soundcloud =
  base: "http://api.soundcloud.com"
  cookieName: "soundcloud_access_token"
  setKey: (key) -> apiKey = key
  token: -> 
    return cookie soundcloud.cookieName
  clearToken: -> 
    cookie soundcloud.cookieName, null
    return soundcloud
  setToken: (val) -> 
    cookie soundcloud.cookieName, val, maxage: 604800000, path: '/'
    return soundcloud

  authorize: (cburl=window.location.origin) ->
    uri = "#{soundcloud.base}/connect/?response_type=token&scope=non-expiring&client_id=#{apiKey}&redirect_uri=#{cburl}"
    window.location.href = uri
    return soundcloud

  makeRequest: (path, opt={}, type, cb) ->
    if typeof opt is 'function' and !cb
      cb = opt
      opt = {}
    uri = "#{soundcloud.base}#{path}"
    req = request[type](uri)

    # headers
    req.set opt.headers if opt.headers

    # qs
    req.query opt.qs if opt.qs


    if soundcloud.token()
      req.query oauth_token: soundcloud.token()
    else
      req.query client_id: apiKey

    req.query
      "_status_code_map[302]": 200
      format: "json"

    # body
    if opt.data
      req.send opt.data

    req.end cb
    return req

  get: (path, opt, cb) ->
    soundcloud.makeRequest path, opt, 'get', cb

  post: (path, opt, cb) ->
    soundcloud.makeRequest path, opt, 'post', cb

  put: (path, opt, cb) ->
    soundcloud.makeRequest path, opt, 'put', cb

  del: (path, opt, cb) ->
    soundcloud.makeRequest path, opt, 'del', cb

tok = getParam "access_token"
soundcloud.setToken tok if tok?

module.exports = soundcloud