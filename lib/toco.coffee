coffee = require 'coffee-script'
colors = require 'colors'

{ EventEmitter } = require 'events'

Reporters =
    default: require './reporters/default'

# Test suite
class Suite
    constructor: (@title) ->
        @tests = []
        @setup = []
        @reporter = Reporters.default

    run: ->
        @passed = 0
        @failed = 0
        @results = []
        if @setup.length
            eval.call null, coffee.compile @setup.join("\n"), { bare: true }
        for test in @tests
            start = Date.now()
            test.run (err, ok) =>
                if err or ok is false then @failed++ else @passed++
                result = err or ok ? true
                end = Date.now()
                @results.push [result, end-start]
                if @passed + @failed is @tests.length
                    @reporter.call @

# Unit test
class Test
    constructor: (@title) ->
        @code = []

    run: (done) ->
        result = undefined
        try
            result = eval.call null, coffee.compile @code.join("\n"), { bare: true }
            unless typeof result is 'function'
                return done null, result
            else
                try result = result.call null, done
                catch err then done err
        catch err
            done err

# Parses a spec file, returns a `Suite`
parse = (source) ->

    suites = []
    currentSuite = null
    currentTest = null

    lines = source.split /[\r\n]+/
    
    for line in lines
        continue unless line.trim()

        # Start a new test suite.
        if line[0..1] is '# '
            suites.push currentSuite if currentSuite?
            currentSuite = new Suite line.substring(2)

        # A single test case.
        else if line[0..2] is '## '
            currentTest = new Test line.substring(3)
            currentSuite.tests.push currentTest

        # Everything else is a code block.
        else if currentTest?
            currentTest.code.push line
        else
            currentSuite.setup.push line
                
    suites.push currentSuite if currentSuite?
    return suites

Toco = (code) ->
    suites = parse code
    suite.run() for suite in suites

module.exports = Toco
