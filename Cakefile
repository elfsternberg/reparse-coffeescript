{exec} = require 'child_process'

task 'lib', 'compile to javascript', ->
    exec ['mkdir -p lib',
          'coffee -o lib -c src/reparse.coffee'].join(' && '), (err) ->
        throw err if err

task 'doc', 'build the ReParse documentation', ->
    exec 'node_modules/.bin/docco src/reparse.coffee', (err) ->
        throw err if err

task 'clean', 'Delete the compiled code and generated documentation', ->
    exec 'rm -fr lib docs', (err) ->
        throw err if err
