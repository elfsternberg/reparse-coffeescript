#; -*- mode: coffee -*-

#      ___     ___                     ___      __  __
#     | _ \___| _ \__ _ _ _ ___ ___   / __|___ / _|/ _|___ ___
#     |   / -_)  _/ _` | '_(_-</ -_) | (__/ _ \  _|  _/ -_) -_)
#     |_|_\___|_| \__,_|_| /__/\___|  \___\___/_| |_| \___\___|
#

# A hand-re-written implementation of Ben Weaver's ReParse, a parser
# combinator, which in turn was heavily influenced by Haskell's
# PARSEC.  In many cases, this code is almost exactly Ben's; in some,
# I've lifted further ideas and commentary from the JSParsec project.

exports.ReParse = class ReParse

    # Extend from ReParse and set to true if you don't care about
    # whitespace.

    ignorews: false

    # Where the parse phase begins.  The correct way to override this
    # is to create a child method:

    #     parse: ->
    #         super
    #         @start(@your_top_level_production)

    parse: (input) =>
        @input = input

    # Returns true when this parser has exhausted its input.

    eof: =>
        @input is ""

    # Indicate failure, optionally resetting the input to a previous
    # state.  This is not an exceptional condition (in choice and
    # maybes, for example).

    fail: (input) =>
        @input = input if input isnt `undefined`
        throw @fail

    # Execute a production, which could be a function or a RegExp.

    produce: (method) =>
        val = if (method instanceof RegExp) then @match(method) else method.call(@)
        @skipWS() if @ignorews
        val

    # Begin parsing using the given production, return the result.
    # All input must be consumed.

    start: (method) =>
        val = undefined
        @ignorews and @skipWS()
        try
            val = @produce method
            return val if @eof()
        catch err
            throw err if err isnt @fail
        throw new Error("Could not parse '" + @input + "'.")


    # Attempts to apply the method and produce a value.  If it fails,
    # restores the input to the previous state.

    maybe: (method) =>
        input = @input
        try
            return @produce method
        catch err
            throw err if err isnt @fail
        @fail input

    # Try to run the production `method`.  If the production fails,
    # don't fail, just return the otherwise.

    option: (method, otherwise) =>
        try
            return @maybe method
        catch err
            throw err if err isnt @fail
        return otherwise

    # Given three parsers, return the value produced by `body`.  This
    # is equivalent to seq(left, body, right)[0].  I'm not sure why
    # Weaver created an alternative syntax, then.  Wishing JSParsec
    # wasn't so damned unreadable.

    between: (left, right, body) =>
        input = @input
        val = undefined
        try
            @produce left
            val = @produce body
            @produce right
            return val
        catch err
            throw err if err isnt @fail
        @fail input

    # Match a regular expression against the input, returning the
    # first captured group.  If no group is captured, return the
    # matched string.  This can result in surprises, if you don't wrap
    # your groups exactly right, which is common in ()? regexps.  Note
    # that this is where the input consumption happens: upon a match,
    # the input is reduced to whatever did not match.  (Note that as
    # the tree of productions is followed, backups of existing input
    # are kept and restored when a possible parse fails.  If your
    # source is very large, this can become problematic in both time
    # and space.)

    match: (pattern) =>
        probe = @input.match pattern
        return @fail()  unless probe
        @input = @input.substr probe[0].length
        if probe[1] is `undefined` then probe[0] else probe[1]

    # Returns the first production among arguments for which the
    # production does not fail.

    choice: =>
        input = @input
        for arg in arguments
            try
                return @produce arg
            catch err
                throw err if err isnt @fail
        @fail input

    # Match every production in a sequence, returning a list of the
    # values produced.  Sometimes Coffeescript's parser surprises me,
    # as in this case where the try-return pairing confused it, and it
    # needed help isolating the element.
    #
    # I have yet to find a case where where Weaver's unshift of the
    # beginning of the input string to the front of the return value
    # makes sense.  It's not a feature of Parsec's sequence primitive,
    # for example.
    #
    # It could be useful if one needed the raw of a seq: for example,
    # when processing XML entities for correctness, not value.  But in
    # the short term, the productions can be as preservative as
    # Weaver's technique, and for my needs that's my story, and I'm
    # sticking to it.

    seq: =>
        input = @input
        try
            return (for arg in arguments
                @produce(arg))
        catch err
            throw err if err isnt @fail
        @fail input

    # Applies the production `method` `min` or more times.  Returns
    # the parser object as a chainable convenience if it does not
    # fail.  Will fail if it skips less than `min` times.

    skip: (method, min = null) =>
        found = 0
        input = @input
        until @eof()
            try
                @maybe method
                found++
            catch err
                throw err if err isnt @fail
                break
        if min and (found < min) then @fail input else @

    # Applies the production `method` one or more times.

    skip1: (method) => @skip(method, 1)

    # Skip whitespace.  Returns the parser object for chainable
    # convenience.  Note that this is the baseline whitespace: this
    # will not skip carriage returns or linefeeds.

    skipWS: =>
        @match(/^\s*/)
        @

    # Returns an array of `min` values produced by `method`.

    many: (method, min = null) =>
        input = @input
        result = until @eof()
            try
                @maybe(method)
            catch err
                throw err if err isnt @fail
            break

        if min and (result.length < min) then @fail input else result

    # Returns an array of at least one values produced by `method`.
    # Fails if zero values are produced.

    many1: (method) => @many method, 1

    # Return the array of values produced by `method` with `sep`
    # between each value.  The series may be terminated by a `sep`.

    sepBy: (method, sep, min = 0) =>
        orig = @input
        input = undefined
        result = []
        try
            result.push @produce method
            until @eof()
                try
                    input = @input
                    @produce sep
                    result.push @produce method
                catch err
                    throw err if err isnt @fail
                    @fail input
        catch err
            throw err if err isnt @fail
        if min and (result.length < min) then @fail orig else result

    sepBy1: (method, sep) => @sepBy method, sep, 1

    # parses `min` or more productions of `method` (zero by default),
    # which must be terminated with the `end` production.  RESOLVE:
    # There is no alternative production being given to `@option` in
    # Weaver's code.  I've changed this to @produce for the time
    # being, which seems to be in line with the JSParsec
    # implementation.

    endBy: (method, end, min = 0) =>
        val = @many method, min
        @produce end
        val

    # Parses 1 or more productions of method, which must be terminated
    # with the end production

    endBy1: (method, end) =>
        @endBy method, end, 1

    # Returns an array of `min` or more values produced by `method`,
    # separated by `sep`, and optionally terminated by `sep`.
    # Defaults to zero productions.

    sepEndBy: (method, sep, min = 0) =>
        val = @sepBy method, sep, min
        @option sep
        val

    # Returns an array of `min` or more values produced by `method`,
    # separated by `sep`, and optionally terminated by `sep`.
    # Defaults to zero productions.  Must return at least one
    # production; fails if there are zero productions.

    sepEndBy1: (method, sep) => @sepEndBy method, sep, 1

    # Process `min` occurrences of `method`, separated by `op`. Return
    # a value obtained by the repeated application of the return of
    # `op` to the return of `method`.  If there are less that `min`
    # occurrences of `method`, `otherwise` is returned.  Used, for
    # example, to process a collection of mathematical productions of
    # the same precedence.  This is analogous to the reduce() function
    # of python, ruby, and ECMA5.

    chainl: (method, op, otherwise = null, min = null) =>
        found = 0
        result = otherwise
        orig = @input
        input = undefined
        try
            result = @maybe(method)
            found++
            until @eof()
                try
                    input = @input
                    result = @produce(op)(result, @produce(method))
                    found++
                catch err
                    throw err  if err isnt @fail
                    @fail input
        catch err
            throw err  if err isnt @fail
        if min and (found < min) then @fail input else result

    # Like `chainl`, but must produce at least one production.  Fails
    # if there are zero productions.

    chainl1: (method, op) => @chainl method, op, null, 1

