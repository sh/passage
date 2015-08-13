UrlPattern = require 'url-pattern'

passage = require '../src/passage'

module.exports =

  'router':

    'matching method and matching url': (test) ->
      middleware = passage.get '/users', (req, res) ->
        test.done()
      req = {url: '/users', method: 'get'}
      res = {}
      middleware req, res, -> test.fail()

    'head is handled like a get': (test) ->
      middleware = passage.get '/users', (req, res) ->
        test.done()
      req = {url: '/users', method: 'head'}
      res = {}
      middleware req, res, -> test.fail()

    'ignore query part of url': (test) ->
      middleware = passage.get '/users', (req, res) ->
        test.done()
      req = {url: '/users?age=27', method: 'get'}
      res = {}
      middleware req, res, -> test.fail()

    'any method and matching url': (test) ->
      middleware = passage.any '/users', (req, res) ->
        test.done()
      req = {url: '/users', method: 'get'}
      res = {}
      middleware req, res, -> test.fail()

    'not matching method and matching url': (test) ->
      middleware = passage.post '/users', (req, res) ->
        test.fail()
      req = {url: '/users', method: 'get'}
      res = {}
      middleware req, res, -> test.done()

    'matching method and not matching url': (test) ->
      middleware = passage.get '/users', (req, res) ->
        test.fail()
      req = {url: '/projects', method: 'get'}
      res = {}
      middleware req, res, -> test.done()

    'params are passed to handler': (test) ->
      middleware = passage.get '/users/:userId/posts/:postId', (req, res, next, params) ->
        test.deepEqual params, {userId: '8', postId: '120'}
        test.done()
      req = {url: '/users/8/posts/120', method: 'get'}
      res = {}
      middleware req, res, -> test.fail()

    'POST': (test) ->
      middleware = passage.post '/users/:id', (req, res, next, params) ->
        test.deepEqual params, {id: '8'}
        test.done()
      req = {url: '/users/8', method: 'post'}
      res = {}
      middleware req, res, -> test.fail()

    'PUT': (test) ->
      middleware = passage.put '/users/:id', (req, res, next, params) ->
        test.deepEqual params, {id: '8'}
        test.done()
      req = {url: '/users/8', method: 'put'}
      res = {}
      middleware req, res, -> test.fail()

    'DELETE': (test) ->
      middleware = passage.delete '/users/:id', (req, res, next, params) ->
        test.deepEqual params, {id: '8'}
        test.done()
      req = {url: '/users/8', method: 'delete'}
      res = {}
      middleware req, res, -> test.fail()

    'PATCH': (test) ->
      middleware = passage.patch '/users/:id', (req, res, next, params) ->
        test.deepEqual params, {id: '8'}
        test.done()
      req = {url: '/users/8', method: 'patch'}
      res = {}
      middleware req, res, -> test.fail()

    'UrlPattern as argument': (test) ->
      pattern = new UrlPattern '/users/:id'
      middleware = passage.get pattern, (req, res, next, params) ->
        test.deepEqual params, {id: '8'}
        test.done()
      req = {url: '/users/8', method: 'get'}
      res = {}
      middleware req, res, -> test.fail()

    'custom matcher object': (test) ->
      test.expect 1
      pattern = new UrlPattern '/language/:slug'
      matcher =
        match: (url) ->
         match = pattern.match url
         if match? and match.slug in ['es', 'fr']
           return match

      middleware = passage.get matcher, (req, res, next, params) ->
        test.deepEqual params, {slug: 'es'}
      req = {url: '/language/es', method: 'get'}
      res = {}
      middleware req, res, -> test.fail()

      middleware = passage.get matcher, (req, res, next, params) ->
        test.fail()
      req = {url: '/language/uk', method: 'get'}
      res = {}
      middleware req, res, ->
        test.done()

  'vhost':

    'match': (test) ->
      middleware = passage.vhost ':sub.example.:tld', (req, res, next, params) ->
        test.deepEqual params, {sub: 'www', tld: 'com'}
        test.done()
      req =
        headers:
          host: 'www.example.com'
      res = {}
      middleware req, res, -> test.fail()

    'no match': (test) ->
      middleware = passage.vhost ':sub.example.:tld', (req, res) ->
        test.fail()
      req =
        headers:
          host: 'www.google.com'
      res = {}
      middleware req, res, -> test.done()
