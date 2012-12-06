coffee = require 'coffee-script'

class Suite
    constructor: (@title) ->
        @tests = []
        @setup = []
    run: ->
        passed = 0
        failed = 0
        if @setup.length
            eval.call null, coffee.compile @setup.join("\n"), { bare: true }
        console.log()
        for test in @tests
            result = test.run()
            if result then passed++ else failed++
            if result instanceof Error
                console.log "✗ #{test.title}"
                console.log result
            else
                console.log "#{if result then '✓' else '✗'} #{test.title}"
        console.log "\n#{passed} tests passed, #{failed} failed\n"
        
class Test
    constructor: (@title) ->
        @code = []
    run: ->
        result = undefined
        try
            result = eval.call null, coffee.compile @code.join("\n"), { bare: true }
        catch e
            result = e
        finally
            return result

parse = (source) ->

    suites = []
    currentSuite = null
    currentTest = null

    lines = source.split /[\r\n]+/
    
    for line in lines
        continue unless line = line.trim()

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
            
file = process.argv[2]

suites = parse require('fs').readFileSync(file).toString()

#console.log suites

suites[0].run()