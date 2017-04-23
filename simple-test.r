REBOL [
    title: "Simple-Test"
    version: 0.1.1
    date: 23-Mar-2010
    author: Peter W A Wood
    file: %simple-test.r
    purpose: {A simple Rebol testing framework}
    library: [
      level: 'intermediate
      platform: 'all
      type: [package tool]
      domain: [test parse]
      license: 'mit
  ]
]

simple-test: make object! [
  
  ;; copy the built-in now function for use in case tests will overwrite it
  test-now: :now
  
  ;; copy the built-in print function for use in case tests will overwrite it
  test-print: :print
  
  ;; verbose flag to control amount of ouput
  verbose: #[false]
  
  ;; overall counts
  final-tests: 0
	final-passed: 0
	final-failed: 0
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;; eval-case object  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; Holds the parse rules for evaluate-case
  eval-case: make object! [
    
	  ;; local variables
	  assertion-no: 0
	  name: #[none]
	  name-not-printed: #[true]
	  result: #[none]
	  result-type: #[none]
	  run-time: #[none]
	  timestamp: #[none]
	  assertion-no: 0
	  actual: #[none]
	  actual-result-type: #[none]
	  expected: #[none]
	  expected-result-type: #[none]
	  any-failures: #[false]
	    
	  ;; "private" methods
	  assert-equal-action: does [
	    inc-assertion-no
      get-actual-result
      get-expected-result
      
      either actual = expected [
        print-passed
      ][
        any-failures: #[true]
        print-failed
        test-print join "^-Expected Value of Type - " compose [(
          either expected-result-type = "unset" [
            "unset!" 
          ][
            join mold type? expected ["^/^-^-" mold :expected]
          ])
          "^/^-Actual Value of Type - " (
          either actual-result-type = "unset" [
            "unset!"
          ][
            join mold type? actual ["^/^-^-" mold :actual]
          ])
        ]
      ]
	  ]
	  
	  assert-error-action: does [
	    inc-assertion-no
	    get-actual-result
	    	    
	    either "error" = actual-result-type [
	      print-passed
	    ][
	      any-failures: #[true]
        print-failed
	    ]
	  ]
	  
	  assert-false-action: does [
	    inc-assertion-no
	    get-actual-result
	    either not actual [
	      print-passed
	    ][
	      any-failures: #[true]
	      print-failed
	    ]
	  ]
	  
	  assert-true-action: does [
	    inc-assertion-no
	    get-actual-result
	    either actual [
	      print-passed
	    ][
	      any-failures: #[true]
	      print-failed
	    ]
	  ]
	  
	  assert-unset-action: does [
	    inc-assertion-no
	    get-actual-result
	    either "unset" = actual-result-type [
	      print-passed
	    ][
	      any-failures: #[true]
	      print-failed
	    ]
	  ]
	  
	  get-actual-result: does [
	    ;; get the actual result
      either all [
        'do = first actual-block
        1 = length? actual-block
      ][
        actual: :result
        actual-result-type: :result-type
      ][
        response: evaluate actual-block
        actual: :response/result
        actual-result-type: :response/result-type
      ]
	  ]
	  
	  get-expected-result: does [
	    ;; evaluate the expected result
      response: evaluate expected-block
      expected: :response/result
      expected-result-type: :response/result-type
    ]
    
    inc-assertion-no: does [
     assertion-no: assertion-no + 1 
    ]
    
	  init: does [
	    any-failures: #[false]
	    assertion-no: 0
	    name: #[none]
	    name-not-printed: #[true]
	    result: #[none]
	    result-type: #[none]
	    run-time: #[none]
	    timestamp: #[none]
	    actual: #[none]
	    actual-result-type: #[none]
	    expected: #[none]
	    expected-result-type: #[none]
	    any-failures: #[false]
	  ]
	  
	  print-failed: does [
	    print-msg join "^-Assertion " [:assertion-no " Failed"]
	  ]
    
    print-passed: does [
	   if verbose [
          print-msg join "^-Assertion " [:assertion-no " Passed"]
        ] 
	  ]
    
    print-msg: func [msg] [
	    if name-not-printed [
	      print-name
	    ]  
	    test-print msg
	  ]
	  
	  print-name: does [
	    test-print join "Test - " [name]
	    name-not-printed: #[false]
	  ]
	  
    ;; object parse rules
    ;; name-rule - stores the test name 
    name-rule: [
      'name set name string!
    ]
    
    ;; setup-rule - evaluates any supplied setup code
    setup-rule: [
      'setup set setup block! (
        response: evaluate setup
        if response/result-type = "error" [
          any-failures: #[true]
          print-msg ["^-setup failed -" response/result-type]
        ]
      )
    ]
    
    ;; teardown-rule - evaluates any supplied teardown code
    teardown-rule: [
      'teardown set teardown block! (
        response: evaluate teardown
        if :response/result-type = "error" [
          any-failures: #[true]
          print-msg ["^-teardown failed -" response/result-type]
        ]
      )
    ]
    
    ;; do-rule - evaluates the code being tested (the do block)
    do-rule: [
      'do set do-block block! (
        response: evaluate do-block
        timestamp: :response/timestamp
        run-time: :response/run-time
        result: :response/result
        result-type: :response/result-type
        if verbose [
          print-msg join "^-On " timestamp
          print-msg join "^-Took " run-time
        ]
      )
    ]
    
    ;; assert-rule - evaluates an assertion supplied to check the test
    assert-rule: [
      assert-equal-rule
      |
      assert-error-rule
      |
      assert-false-rule
      |
      assert-true-rule
      |
      assert-unset-rule
    ]
    
    ;; assert sub-rules
    assert-equal-rule: [
      'assert 'equal set actual-block [block!] set expected-block [block!] (
        assert-equal-action
      )
    ]
    
    assert-error-rule: [
      'assert 'error set actual-block [block!] (
        assert-error-action
      )
    ]
    
    assert-false-rule: [
      'assert 'false set actual-block [block!] (
        assert-false-action
      )
    ]
    
    assert-true-rule: [
      'assert 'true set actual-block [block!] (
        assert-true-action
      )
    ]
    
    assert-unset-rule: [
      'assert 'unset set actual-block [block!] (
        assert-unset-action
      )
    ]
    
    ; MAIN RULE
    rules: [
      (init)
      name-rule 
      opt setup-rule
      do-rule
      some assert-rule
      opt teardown-rule
      end
    ]
    
  ] ;; end eval-case object
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;; eval-set object  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; Holds the parse rules for evaluate-set
  eval-set: make object! [
    
	  ;; local variables
	  name: #[none]
	  setup-each: #[none]
	  teardown-each: #[none]
	  teardown-once: #[none]
	  no-tests: 0
	  no-passed: 0
	  no-failed: 0
	  
	  ;; "private" methods
	  init: does [
	    name: #[none]
	    setup-each: #[none]
	    teardown-each: #[none]
	    teardown-once: #[none]
	    no-tests: 0
	    no-passed: 0
	    no-failed: 0
	    simple-test/verbose: #[false]
	  ]
	  
	  teardown-and-print: does [
	    if teardown-once [
	      response: evaluate teardown-once
        if :response/result-type = "error" [
          test-print ["Teardown failed -" response/result-type]
        ]
      ]
	    test-print join "Totals" [
	      newline
	      "^-Tests  = " no-tests newline
	      "^-Passed = " no-passed newline
	      "^-Failed = " no-failed
	    ]
	  ]
	  
    ;; object parse rules
    ;; name-rule - stores the test name 
    name-rule: [
      'set 'name set name string! (
        test-print join "Test Set " [name]
      )
    ]
    
    ;; setup-each-rule - stores the setup code
    setup-each-rule: [
      'setup 'each set setup-each block!
    ]
    
    ;; setup-once-rule - evaluates any supplied setup code
    setup-once-rule: [
      'setup 'once set setup block! (
        response: evaluate setup
        if :response/result-type = "error" [
          test-print ["Setup once failed -" response/result-type]
        ]
      )
    ]
    
    ;; teardown-each-rule - stores the teardown code
    teardown-each-rule: [
      'teardown 'each set teardown-each block!
    ]
    
    ;; teardown-once-rule - stores any teardown code to run after test cases
    teardown-once-rule: [
      'teardown 'once set teardown-once block!
    ]
    
    ;; test-case rule - evaluates a test case
    test-case-rule: [
      'test 'case set test-case block! (
        no-tests: no-tests + 1
        if setup-each [
          response: evaluate setup-each
          if :response/result-type = "error" [
            test-print ["Setup each failed -" response/result-type]
          ]
        ]
        either evaluate-case test-case [
          no-passed: :no-passed + 1
        ][
          no-failed: :no-failed + 1
        ]
        
        if teardown-each [
          response: evaluate teardown-each
          if :response/result-type = "error" [
            test-print ["Teardown each failed -" response/result-type]
          ]
        ]
      )
    ]
    
    ; MAIN RULE
    rules: [
      (init)
      opt ['verbose (simple-test/verbose: #[true])]
      name-rule 
      opt setup-once-rule
      opt setup-each-rule
      opt teardown-each-rule
      opt teardown-once-rule
      some test-case-rule
      end (teardown-and-print)
    ]
    
  ] ;; end eval-set object
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
    
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;; evaluate function  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  evaluate: func [
    {
      Evaluates the supplied code and returns a rebol block 
      about the evaluation:
        [
          code-block - block! - the code block evaluated
          timestamp - date! -  the time of evaluation
          run-time - time! - the execution time of the evaluation
          result - any! - the result of the evaluation
                        - this will be an error object if an error occurred
                        - none if the result is unset
          result-type - "normal" - evaluation produced a result
                      - "error" - an error occurred during evalutaion
                      - "unset" - the evaluation returned unset
        ]
    }
    code-block [block!] "Format [code]"
    /local
      timestamp "The time of evaluation"
      start "The start time of evaluation"
      end "The end time of evaluation"
      run-time "The time taken to perform the evaluation"
      result "The result of the evaluation"
      result-type {"normal", "error" or "unset"}
  ][
    ;; initialisations
    timestamp: #[none]
    start: #[none]
    end: #[none]
    run-time: #[none]
    result: #[none]
    result-type: copy "normal"
    error: #[none]
      
    ;; evaluate the code
    timestamp: test-now/precise
    start: test-now/precise
    if error? set/any 'result try code-block [
      ;; catch errors in the evaluation of the code block
      result: disarm result
      result-type: copy "error"
    ]
    end: test-now/precise
    ;; catch cases where the codeblock evaluates to unset
    if all [
      :result-type <> "error"
      error? set/any 'result try [result]
    ][
      result: #[none]
      result-type: copy "unset"
    ] 

    run-time: difference end start
 
    ;; create and return the output
    compose/only [
      code-block (:code-block) timestamp (:timestamp)
      run-time (:run-time) result (:result) result-type (:result-type)
    ]
  
  ] ;; end of evaluate function
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;; evaluate-case ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  evaluate-case: func [
  	{Evaluates a single test case presented in the following dialect:
            name "test identifer"
  	        opt setup [setup code]
            do [the code being tested - this will be timed]
            some assert-XXXXX [assertions to check the result]
            opt teardown [teardown code]
    }
	  the-test [block!]
  ][
    either parse the-test eval-case/rules [
      either eval-case/any-failures [
        #[false]
      ][
        #[true]
      ]
    ][
      either eval-case/name-not-printed [
        test-print join 
          "Invalid test case" [newline tab copy/part mold the-test 20]
      ][
        test-print "^-Invalid test case"
      ]
      #[false]
    ]
	  
  ] ;; end of evaluate-case
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;; evaluate-set function  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  evaluate-set: func [
  	"Evaluates a set of tests"
	  test-set [block!] "Format: [command [attributes]]"
  ][
    either parse test-set eval-set/rules [
      final-tests: final-tests + eval-set/no-tests
      final-passed: final-passed + eval-set/no-passed
      final-failed: final-failed + eval-set/no-failed
      compose [
        name (eval-set/name)
        tests (eval-set/no-tests)
        passed (eval-set/no-passed)
        failed (eval-set/no-failed)
      ]
    ][
      test-print "Test halted - syntax error"
      #[false]
    ]
    
    
  ] ;; end of evaluate-set
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;;;;;;;;;;;;;;;;;; init-final-totals function  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  init-final-totals: func [][
    final-tests: 0
	  final-passed: 0
	  final-failed: 0
  ] ;; end of init-final-totals
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;;;; print-final-totals function  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print-final-totals: func [][
    test-print " "
    test-print join "Overall Tests " final-tests
	  test-print join "       Passed " final-passed
	  test-print join "       Failed " final-failed
  ] ;; end of print-final-totals
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;; run-tests function  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  run-tests: func [
  	{Runs tests - either a set or suite of tests using recursion}
	  tests[file!]
  ][
    test-data: load tests
    either 'suite = first test-data [
      foreach suite-or-set second test-data [
        run-tests suite-or-set
      ]
    ][
      simple-test/evaluate-set test-data
    ] 
  ] ;; end of run-tests
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

] ;; end of test object!

run-test: func [
  {A wrapper for tests/run-tests in the global context}
  tests [file!]
][
  simple-test/init-final-totals
  simple-test/run-tests tests
  simple-test/print-final-totals
  #[unset!]
]
