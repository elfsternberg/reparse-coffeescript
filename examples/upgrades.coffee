# Taken from https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Array/Reduce

if not Array::reduce?
    Array::reduce = ->
        accumulator = arguments[0]
        ctr = 0

        if typeof accumulator != 'function'
            throw new TypeError "First argument is not callable"

        curr = if arguments.length < 2
            if @length == 0 then throw new TypeError "Array length is 0 and no second argument"
            ctr = 1
            @[0]
        else
            arguments[1]

        for i in [ctr...@length]
            curr = accumulator.call(undefined, curr, @[i], i, @)

        curr
