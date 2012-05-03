ReParse = require('../src/reparse').ReParse
util = require("util")

class Calc extends ReParse
    ignorews: true

    OPS:
        '+': (a, b) -> a + b
        "-": (a, b) -> a - b
        "*": (a, b) -> a * b
        "/": (a, b) -> a / b

    expr:   => @chainl @term, @addop
    term:   => @chainl1 @factor, @mulop
    factor: => @choice @group, @number
    group:  => @between /^\(/, /^\)/, @expr
    number: => parseFloat @match(/^(\-?\d+(\.\d+)?)/)
    mulop:  => @OPS[@match(/^[\*\/]/)]
    addop:  => @OPS[@match(/^[\+\-]/)]

    parse:  =>
        super
        @start(@expr)

unless process.argv.length is 3
  util.puts "Usage: node " + process.argv[1] + " expression"
  process.exit 1

util.puts (new Calc).parse(process.argv[2])
