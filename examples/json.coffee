ReParse = require('../src/reparse').ReParse
util = require("util")
peg = require('./pegjson').parser;
require('./upgrades')

class ReJSON extends ReParse
    ignorews: true

    LITERAL = {'true': true, 'false': false, 'null': null}
    STRING = {"\"": 34, "\\": 92, "/": 47, 'b': 8, 'f': 12, 'n': 10, 'r': 13, 't': 9}

    value:    => @choice @literal, @string, @number, @array, @object
    object:   => @between('{', '}', @members).reduce ((obj, pair) => obj[pair[0]] = pair[2]; obj), {}
    members:  => @sepBy @pair, ','
    pair:     => @seq @string, ':', @value
    array:    => @between '[', ']', @elements
    elements: => @sepBy @value, /^,/
    literal:  => LITERAL[@m(/^(true|false|null)/)]
    number:   => parseFloat @m(/^\-?\d+(?:\.\d+)?(?:[eE][\+\-]?\d+)?/)

    string: =>
        chars = @m(/^"((?:\\["\\/bfnrt]|\\u[0-9a-fA-F]{4}|[^"\\])*)"/)
        chars.replace /\\(["\\/bfnrt])|\\u([0-9a-fA-F]{4})/g, (_, $1, $2) =>
            String.fromCharCode (if $1 then STRING[$1] else parseInt($2, 16)) # "

    parse:  =>
        super
        @start(@value)


capture = (stream, encoding, fn) =>
    data = ""
    stream.setEncoding encoding
    stream.on "data", (chunk) => data += chunk
    stream.on "end", => fn data

time = (label, reps, fn) =>
    start = Date.now()
    for i in [0..reps]
        fn()
    util.puts label + ": " + (Date.now() - start)

input = "{\"a\": [1, \"foo\", [], {\"foo\": 1, \"bar\": [1, 2, 3]}] }"
console.log util.inspect (new ReJSON).parse( input), false, 4

jsonparse = new ReJSON()

time "JSON", 1000, =>   JSON.parse input
time "PEG.js", 1000, =>   peg.parse input
time "ReParse", 1000, =>   jsonparse.parse(input)
