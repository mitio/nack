http = require 'http'

{createServer} = require 'nack/server'

exports.testProxyRequest = (test) ->
  test.expect 2

  server = createServer __dirname + "/fixtures/hello.ru"

  server.on 'close', ->
    test.ok true
    test.done()

  server.listen 0
  server.on 'listening', ->
    http.cat "http://127.0.0.1:#{server.address().port}/", "utf8", (err, data) ->
      test.ok !err
      server.close()

exports.testProxyRequestWithClientException = (test) ->
  test.expect 3

  server = createServer "#{__dirname}/fixtures/error.ru"
  server.use (err, req, res, next) ->
    test.ok err
    res.writeHead 500, 'Content-Type': 'text/plain'
    res.end()

  server.on 'close', ->
    test.ok true
    test.done()

  server.listen 0
  server.on 'listening', ->
    http.cat "http://127.0.0.1:#{server.address().port}/", "utf8", (err, data) ->
      test.ok err
      server.close()

exports.testProxyRequestWithErrorCreatingProcess = (test) ->
  test.expect 3

  server = createServer "#{__dirname}/fixtures/crash.ru"
  server.use (err, req, res, next) ->
    test.ok err
    res.writeHead 500, 'Content-Type': 'text/plain'
    res.end()

  server.on 'close', ->
    test.ok true
    test.done()

  server.listen 0
  server.on 'listening', ->
    http.cat "http://127.0.0.1:#{server.address().port}/", "utf8", (err, data) ->
      test.ok err
      server.close()

exports.testProxyCookies = (test) ->
  test.expect 2

  server = createServer __dirname + "/fixtures/echo.ru"

  server.on 'close', ->
    test.ok true
    test.done()

  server.listen 0
  server.on 'listening', ->
    http.cat "http://127.0.0.1:#{server.address().port}/", "utf8", (err, data) ->
      test.ifError err
      server.close()

exports.testCloseServer = (test) ->
  test.expect 2

  server = createServer __dirname + "/fixtures/hello.ru"

  server.on 'close', ->
    test.ok true
    test.done()

  server.listen 0
  server.on 'listening', ->
    test.ok true
    server.close()

exports.testCloseUnstartedServer = (test) ->
  test.expect 1

  server = createServer __dirname + "/fixtures/hello.ru"

  server.on 'close', ->
    test.ok true
    test.done()

  server.close()

exports.testRestartServerWithActiveWorkers = (test) ->
  test.expect 3

  server = createServer __dirname + "/fixtures/echo.ru"

  server.on 'exit', ->
    test.ok true
    test.done()

  server.listen 0
  server.on 'listening', ->
    http.cat "http://127.0.0.1:#{server.address().port}/", "utf8", (err, data) ->
      test.ifError err

      server.restart ->
        test.ok true
        server.close()

exports.testRestartServerWithNoActiveWorkers = (test) ->
  test.expect 2

  server = createServer __dirname + "/fixtures/hello.ru"

  server.on 'close', ->
    test.ok true
    test.done()

  server.listen 0
  server.on 'listening', ->
    server.restart ->
      test.ok true
      server.close()
