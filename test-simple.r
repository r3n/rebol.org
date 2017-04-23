REBOL [
    Title: "Simple Test Suite"
    file: %test-simple.r
    date: 15-June-2006
    author: "Brian Wisti"
    home: none
    email: "brianwisti@yahoo.com"
    Version: 0.3.0
    purpose: {
      Add support for simple test mechanisms to REBOL, similar to Perl's 
      Test::Simple. 
      
      The basic idea? Make testing simple so everybody can make tests.
    }
    Library: [
        level: 'beginner
        platform: 'all
        type: [module tool]
        domain: [debug testing]
        tested-under: [Linux Windows]
        support: [
            { This release should be considered 'beta' quality.
              I need suggestions for ways to improve it while maintaining 
              the simplicity of the interface.
              }
        ]
        license: 'mit
        see-also: none
    ]
    changes: [
        [ 7-mar-2005  0.1.0 "Initial Posting on rebol.org" ]
        [ 8-mar-2005  0.1.1 "Default behavior is now to print test results to stdout" ]
		[ 18-aug-2005 0.2.0 "Added a match function for the common test of comparing two values" ]
		[ 15-June-2006 0.3.0 "Added preliminary support for test suites - grouped tests" ]
    ]
]

test: make object! [
    use-stdout: false
    name: "Test"

    test-count: 0
    pass-count: 0
    success-string: "OK"
    failure-string: "Not OK"
    wrapup-message: copy ""
	test-log: make list! []

    ok: func [
        "Test if a condition is true"
        test-condition [block!] "The condition to be tested"
        /log "If you want to log a message on success"
        message        [string!]  "optional string to display on success"
        
        /local 
        test-result results
    ] [
    	results: make list! []
        test-count: test-count + 1
        test-result: do test-condition
        if test-result == true [
        	pass-count: pass-count + 1
    	]
    	results: append results test-result
    	if log [
    		results: append results message
		]
        test-log: append/only test-log results
        if use-stdout [ 
			print results
		]
        return test-result
    ]

	match: func [
		"Shorthand test for comparing 2 values"
		values
		/log
		  message 
		/local
		  description
		  match-test
		  last-test
	] [
		values: reduce values

		match-test: [ values/1 = values/2 ]
		result: either log [
			ok/log match-test message
		] [
			ok/log match-test ""
		]

		last-test: last test-log
		last-test: append/only last-test values
		return result
	]
		
    
    wrapup: func [
        "Returns a summary of test results"
    ] [
    	if wrapup-message = "" [
        	wrapup-message: join name [ ": " pass-count  "/" test-count " passed" ]
    	]
        if use-stdout [ print wrapup-message ]
        return wrapup-message
    ]

	summary: func [
		"Returns the output logged from assertions run"
		/full
		"Display usually ignored output for passed tests"
		/local
		output output-text entry entry-text
	] [
		output: make list! []
		output-text: copy ""
		
		forall test-log [
			entry-text: copy ""
			entry: first test-log
			if any [full entry/1 == false] [
				entry-text: rejoin [
					index? test-log
					" "
					either entry/1 = true [ success-string ] [ failure-string ]
					either (length? entry) >= 2 [ 
						rejoin [ " " entry/2 ]
					] [ "" ]
					either (length? entry) >= 3 [
						rejoin [
							"^/Expected: <" (mold entry/3/1) ">^/"
							  "Got:      <" (replace/all (mold entry/3/2) "^/" "^^/") ">"
						]
					] [ "" ]
				]
			]
			if entry-text <> "" [
				output: append/only output entry-text
			]
		]
		forall output [
			output-text: append output-text output/1
			output-text: append output-text "^/"
		]
		return output-text
	]
]

test-suite: make object! [ 
	tests: make list! []
	tests-ran: make list! []
	
	add-test: func [
		"Adds a new test to the suite"
		test-case "The test object to be added"
	] [
		tests: append/only tests test-case
		return length? tests
	]
	
	run-tests: func [
		"Invoke the tests added to this suite"
	] [
		tests-ran: make list! []
		
		foreach my-test tests [
			tests-ran: append/only tests-ran make test my-test
		]
		
		return length? tests-ran
	]
	
	wrapup: func [
		"Get wrapup information about tests run"
		/local
		message wrapups
	] [
		wrapups: make list! []
		message: copy ""
		foreach my-test tests-ran [
			wrapups: append wrapups my-test/wrapup
		]
		forall wrapups [
			message: join message [ wrapups/1 "^/" ]
		]
		return message
	]
	
	summary: func [
		"Get summary information about tests run"
		/full
		"Display usually ignored output for passed tests"
		/local
		message
		test-message
	] [
		message: copy ""
		foreach my-test tests-ran [
			either full [
				message: join message [ my-test/name ": " my-test/summary/full ]
			] [
				message: my-test/summary
				if message <> "" [
					message: rejoin [ my-test/name ": " message ]
				]
			]
		]
		return message
	]
	
	summarize: func [
		"Get combined summary and wrapup information for tests run"
		/full
		"Get full summaries for each test run"
		/local
		message output
	] [
		message: copy ""
		output: copy ""
		
		foreach my-test tests-ran [
			message: join my-test/wrapup [
				"^/"
				either full [
					my-test/summary/full
				] [
					my-test/summary
				]
			]
			output: rejoin [ output message ]
		]
		
		return output
	]
]

comment {
    The MIT License

    Copyright (c) 2005 Brian Wisti

    Permission is hereby granted, free of charge, to any person 
    obtaining a copy of this software and associated documentation files 
    (the "Software"), to deal in the Software without restriction, 
    including without limitation the rights to use, copy, modify, merge, 
    publish, distribute, sublicense, and/or sell copies of the Software, 
    and to permit persons to whom the Software is furnished to do so, 
    subject to the following conditions:

    The above copyright notice and this permission notice shall be 
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
    BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
    ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
    SOFTWARE.
}

