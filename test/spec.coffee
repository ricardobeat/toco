# Bacon
bacon = 'delicious'
pan = {
    fry: (n, cb) ->
        setTimeout cb, +n or 0
}

## Is good
bacon is 'good'

## Is delicious
bacon is 'delicious'

## Is asynchronous
(done) -> pan.fry 500, done
