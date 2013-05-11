ReParse = require('../src/reparse').ReParse
util = require("util")

class EmailAddress extends ReParse

    addressList:  =>  @sepEndBy @address, /^\s*,\s*/
    address:      =>  @choice @namedAddress, @bareAddress
    namedAddress: =>  @seq(@phrase, /^\s*</m, @bareAddress, '>')[2]
    bareAddress:  =>  @seq(@word, '@', @word).join ""
    phrase:       =>  @many @word
    word:         =>  @skip(/^\s+/).choice @quoted, @dottedAtom
    quoted:       =>  @m /^"(?:\\.|[^"\r\n])+"/m
    dottedAtom:   =>  @m /^[!#\$%&'\*\+\-\/\w=\?\^`\{\|\}~]+(?:\.[!#\$%&'\*\+\-\/\w=\?\^`\{\|\}~]+)*/m

    parse:        =>
        super
        @start(@addressList)

unless process.argv.length is 3
  util.puts "Usage: node " + process.argv[1] + " list-of-addresses"
  process.exit 1

console.log util.inspect (new EmailAddress).parse(process.argv[2])
