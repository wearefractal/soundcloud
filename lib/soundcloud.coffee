cookie = require 'cookie'

apiKey = null

getParam = (param) ->
  url = window.location.hash
  re = new RegExp "##{param}=([^&]+)(&|$)"
  match = url.match re
  return unless match? and match[1]?
  return match[1]

soundcloud =
  base: "https://api.soundcloud.com"
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

    # query encoder
    query = (queryObj) ->
      if queryObj
        return encodeURIComponent(k)+"="+encodeURIComponent(v)+"&" for k, v of queryObj

    if typeof opt is 'function' and !cb
      cb = opt
      opt = {}
    uri = "#{soundcloud.base}#{path}"
    req = new XMLHttpRequest()
    qs  = ""

    # on response
    req.onreadystatechange = ->
      if req.readyState is 4 and req.status is 200
        cb null, req.responseText
     
    # qs
    qs = query opt.qs if opt.qs

    # headers
    if opt.headers
      req.setRequestHeader(header, value) for header, value of opt.headers

    if soundcloud.token()
      qs += query oauth_token: soundcloud.token()
    else
      qs += client_id: apiKey

    qs += query
      "_status_code_map[302]": 200
      format: "json"

    # TODO: body
    # if opt.data
    
    if type is "get" and qs? then uri += "?#{qs}"

    req.open type, uri, true

    if type is "post" and qs?
      req.send qs
    else
      req.send()

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