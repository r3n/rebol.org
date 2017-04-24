REBOL [
    title: "Simple-Test"
    version: 0.4.1
    date: 12-Mar-2011
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
  
  ;; copy the built-in now function for use in case tests overwrite it
  test-now: :now
  
  ;; copy the built-in print function for use in case tests overwrite it
  test-print: :print
  
  ;; if the disarm function is not defined assume we are are running under R3
  ;;  define a disarm function
  if not word? 'disarm [
    disarm: func [value][:value]
  ]  
  
  ;; verbose flag to control amount of output
  verbose: false
  
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
	  name: none
	  name-not-printed: true
	  result: none
	  result-type: none
	  run-time: none
	  timestamp: none
	  assertion-no: 0
	  actual: none
	  actual-result-type: none
	  expected: none
	  expected-result-type: none
	  tolerance: none
	  tolerance-result-type: none
	  any-failures: false
	  response: none
	  test-result: none
	  tr: none
	    
	  ;; "private" methods
	  assert-act-exp-action: func [
	    action [block!]
	    /local
	    rb                            ;; result block
	    res                           ;; test result
	    assertion                     ;; the asertion to be made
	  ][
	    inc-assertion-no
      get-actual-result
      get-expected-result
      assertion: copy [:actual :expected]
      insert assertion action
      either all [
        equal? :actual-result-type "normal"
        equal? :expected-result-type "normal"
        do assertion
      ][
        res: "passed"
      ][
        res: "failed"
      ]
      rb: reduce [
        'result :res
        'actual mold :actual
        'actual-restype :actual-result-type
        'expected mold :expected
        'expected-restype :expected-result-type
      ]   
      
      append test-result/assertions reduce [to-word join "a" assertion-no rb]
	  ]
	  
	  assert-result-type-action: func [
	    expected-result-type [string!]
	    /local
	    rb                            ;; result block
	    res                           ;; test result
	  ] [
	    inc-assertion-no
	    get-actual-result
	    	    
	    either equal? expected-result-type actual-result-type [
	      res: "passed"
	    ][
	      res: "failed"
	    ]
	    rb: reduce [
        'result :res
        'actual mold :actual
        'actual-restype :actual-result-type
      ]   
      
      append test-result/assertions reduce [to-word join "a" assertion-no rb]
	    
	  ]
	  
	  assert-equal-tolerance-action: func [
	    /local
	    rb                            ;; result block
	    res                           ;; test result
	  ][
	    inc-assertion-no
      get-actual-result
      get-expected-result
      get-tolerance-result
      
      either all [
        equal? :actual-result-type "normal"
        equal? :expected-result-type "normal"
        equal? :tolerance-result-type "normal"
        number? :actual
        number? :expected
        number? :tolerance
        tolerance >= abs (actual - expected)  
      ][
        res: "passed"
      ][
        res: "failed"
      ]
      rb: reduce [
        'result :res
        'actual mold :actual
        'actual-restype :actual-result-type
        'expected mold :expected
        'expected-restype :expected-result-type
        'tolerance mold :tolerance
        'tolerance-restype :tolerance-result-type
      ]   
      
      append test-result/assertions reduce [to-word join "a" assertion-no rb]
	  ]
	  
	  assert-result-type-action: func [
	    expected-result-type [string!]
	    /local
	    rb                            ;; result block
	    res                           ;; test result
	  ] [
	    inc-assertion-no
	    get-actual-result
	    	    
	    either equal? expected-result-type actual-result-type [
	      res: "passed"
	    ][
	      res: "failed"
	    ]
	    rb: reduce [
        'result :res
        'actual mold :actual
        'actual-restype :actual-result-type
      ]   
      
      append test-result/assertions reduce [to-word join "a" assertion-no rb]
	    
	  ]
	  
	  assert-not-error-action: func [
	    /local
	    rb                            ;; result block
	    res                           ;; test result
	  ] [
	    inc-assertion-no
	    get-actual-result
	    	    
	    either not equal? actual-result-type "error" [
	      res: "passed"
	    ][
	      res: "failed"
	    ]
	    rb: reduce [
        'result :res
        'actual mold :actual
        'actual-restype :actual-result-type
      ]   
      
      append test-result/assertions reduce [to-word join "a" assertion-no rb]
	    
	  ]
	  
	  assert-logic-action: func [
      /assert-false
	    /local
	    rb                            ;; result block
	    res                           ;; test result
	  ][
	    inc-assertion-no
	    get-actual-result
	    
	    either actual-result-type = "normal" [
	      either assert-false [
	        res: either actual =  false ["passed"] ["failed"]
	      ][
	        res: either actual = true  ["passed"] ["failed"]
	      ]
	    ][
	      res: "failed"
	    ]
	    
	    rb: reduce [
	      'result :res
	      'actual mold :actual
	      'actual-restype :actual-result-type
	    ]
	    
	    append test-result/assertions reduce [to-word join "a" assertion-no rb]
	  ]
	  
	  get-actual-result: does [
	    ;; get the actual result
      either all [
        unset! <> type? first actual-block 
        equal? 'do first actual-block
        equal? 1 length? actual-block
      ][
        actual: :tr
        actual-result-type: select test-result 'result-type
      ][
        response: evaluate :actual-block
        actual: select response 'result
        actual-result-type: :response/result-type
      ]
	  ]
	  
	  get-expected-result: does [
	    ;; evaluate the expected result
      response: evaluate :expected-block
      expected: select response 'result
      expected-result-type: :response/result-type
    ]
    
    get-tolerance-result: does [
	    ;; evaluate the tolerance result
      response: evaluate :tolerance-block
      tolerance: select response 'result
      tolerance-result-type: :response/result-type
    ]
    
    inc-assertion-no: does [
     assertion-no: add assertion-no 1 
    ]
    
	  init: does [
	    assertion-no: 0
	    name: none
	    actual: none
	    actual-result-type: none
	    expected: none
	    expected-result-type: none
	    tolerance: none
	    tolerance-result-type: none
	    test-result: copy [
	      status "normal"
	      case "not set"
	      timestamp "not set"
	      run-time "not set"
	      result "not set"
	      result-type "not set"
	      assertions "not set"
	    ]
	    test-result/assertions: copy []
	  ]
	  

    ;; object parse rules
    ;; name-rule - checks for properly formatted name
    name-rule: [
      'name string! 
    ]
    
    ;; setup-rule - evaluates any supplied setup code
    setup-rule: [
      'setup set setup [block!] (
        response: evaluate :setup
        if equal? :response/result-type "error" [
          test-result/status: "setup failure"
        ]
      )
    ]
    
    ;; teardown-rule - evaluates any supplied teardown code
    teardown-rule: [
      'teardown set teardown [block!] (
        response: evaluate :teardown
        if equal? :response/result-type "error" [
          either equal? test-result/status "setup failure" [
            test-result/status: "setup & teardown failure"
          ][
            test-result/status: "teardown failure"
          ]
        ]
      )
    ]
    
    ;; do-rule - evaluates the code being tested (the do block)
    do-rule: [
      'do set do-block [block!] (
        response: evaluate :do-block
        test-result/timestamp: mold :response/timestamp
        test-result/run-time: mold :response/run-time
        tr: select response 'result
        test-result/result: mold :tr
        test-result/result-type: :response/result-type
      )
    ]
    
    ;; assert-rule - evaluates an assertion supplied to check the test
    assert-rule: [
      assert-equal-rule
      |
      assert-equal-tolerance-rule
      |
      assert-error-rule
      |
      assert-false-rule
      |
      assert-not-equal-rule
      |
      assert-not-error-rule
      |
      assert-not-same-rule
      |
      assert-same-rule
      |
      assert-true-rule
      |
      assert-unset-rule
    ]
    
    ;; assert sub-rules
    assert-equal-rule: [
      'assert 'equal set actual-block block! set expected-block block! (
        assert-act-exp-action [equal?]
      )
    ]
    
    assert-equal-tolerance-rule: [
      'assert 'equal opt 'with 'tolerance 
      set actual-block block!
      set expected-block block!
      set tolerance-block block! (
        assert-equal-tolerance-action 
      )
    ]
    
    assert-error-rule: [
      'assert 'error set actual-block block! (
        assert-result-type-action "error"
      )
    ]
    
    assert-false-rule: [
      'assert 'false set actual-block block! (
        assert-logic-action/assert-false
      )
    ]
    
    assert-not-equal-rule: [
      'assert 'not 'equal set actual-block block! set expected-block block! (
        assert-act-exp-action [not equal?]
      )
    ]
    
    assert-not-error-rule: [
      'assert 'not 'error set actual-block block! (assert-not-error-action)
    ]
    
    assert-not-same-rule: [
      'assert 'not 'same set actual-block block! set expected-block block! (
        assert-act-exp-action [not same?]
      )
    ]
    
    assert-same-rule: [
      'assert 'same set actual-block block! set expected-block block! (
        assert-act-exp-action [same?]
      )
    ]
      
    assert-true-rule: [
      'assert 'true set actual-block block! (
        assert-logic-action
      )
    ]
    
    assert-unset-rule: [
      'assert 'unset set actual-block block! (
        assert-result-type-action "unset"
      )
    ]
    
    ; MAIN RULE
    rules: [
      name-rule 
      opt setup-rule
      do-rule
      some assert-rule
      opt teardown-rule
    ]
    
  ] ;; end eval-case object
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;; eval-set object  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; Holds the parse rules for evaluate-set
  eval-set: make object! [
    
	  ;; local variables
	  name: none
	  setup-each: none
	  teardown-each: none
	  teardown-once: none
	  no-tests: 0
	  passes: 0
	  failures: 0
	  any-failures: false
	  
	  ;; "private" methods
	  init: does [
	    name: none
	    setup-each: none
	    teardown-each: none
	    teardown-once: none
	    no-tests: 0
	    passes: 0
	    failures: 0
	    simple-test/verbose: false
	    any-failures: false
	  ]
	  
	  perform-setup-each: does [
	    response: evaluate :setup-each
      if equal? :response/result-type "error" [
        test-print ["^-Setup each failed"]
      ]
	  ]
	  
	  perform-teardown-each: does [
	    response: evaluate :teardown-each
      if equal? :response/result-type "error" [
        test-print ["^-Teardown each failed"]
      ]
	  ]
	  
	  
	  print-type-value: func [act-exp [string!] type [string!] val [string!]][
	    switch  type [
	      "normal" [
	        test-print rejoin [
	          "^-" :act-exp " - type - " type? do val "^/^-" val
	        ]
	      ]
	      "error" [
	        test-print rejoin ["^-" :act-exp " - type - error!"]
	        test-print join "^-" val
	      ]
	      "unset" [
	        test-print  rejoin ["^-" :act-exp " - type - unset!"]
	      ]
	    ]
	  ]
	  
	  process-case-result: func [
	    cr [block!]
	  ][
	    if cr/status = "Invalid test case" [
	      test-print join "^/" [cr/status]
	      test-print rejoin ["^-" mold cr/case]
	      return none
	    ]
	    
	    ;; any failures ?
	    any-failures: false
	    foreach [a-no a-blk] cr/assertions [ 
	      if not equal? a-blk/result "passed" [any-failures: true]
	    ]
	    
	    either any-failures [
	      failures: add failures 1
	    ][
	      passes: add passes 1
	    ]
	    
	    ;; print test case name if required	    
	    if any [
	      any-failures
	      not equal? cr/status "normal"
	      simple-test/verbose
	    ][
	      test-print rejoin [
	        "^/Test - " cr/case/name 
	        either any-failures [" - *** failed ***"][" - passed"]
	      ]
	    ]
	    
	    if not equal? cr/status "normal" [test-print join "^-" cr/status]
	    
	    ;; print test case result if required
	    if any [
	      any-failures
	      simple-test/verbose
	    ][
	      test-print join "" [
	        "^-On " cr/timestamp "^/"
	        "^-Took " cr/run-time
	      ]
	    
	      foreach [a-no a-blk] cr/assertions [
	        test-print rejoin [
	          "^-Assertion " 
	          remove to-string a-no                  ;; strip off leading a
	          " " a-blk/result
	        ]
	        if not equal? a-blk/result "passed" [
	          print-type-value "actual" a-blk/actual-restype a-blk/actual
	          
	          if find a-blk 'expected [
	            print-type-value "expected" a-blk/expected-restype a-blk/expected
	          ]
	        ]	      
	      ]
	    ]
	  ]
	      
	  teardown-and-print: does [
	    if teardown-once [
	      response: evaluate teardown-once
        if equal? :response/result-type "error" [
          test-print ["^-Teardown once failed"]
        ]
      ]
	    test-print join "Totals^/" [
	      "^-Tests  = " no-tests #"^/"
	      "^-Passed = " passes #"^/"
	      "^-Failed = " failures
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
        response: evaluate :setup
        if equal? :response/result-type "error" [
          test-print ["^-Setup once failed"]
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
          perform-setup-each
        ]
        
        process-case-result evaluate-case :test-case
        
        if teardown-each [
          perform-teardown-each
        ]
      )
    ]
    
    ; MAIN RULE
    rules: [
      (init)
      opt ['verbose (simple-test/verbose: true)]
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
  ;;;;;;;;;;;;;;;;;;;;; evaluate function  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
    code-block [block!]       ; Format [code]
    /local
    timestamp                 ; The time of evaluation
    start                     ; The start time of evaluation
    end                       ; The end time of evaluation
    run-time                  ; The time taken to perform the evaluation
    result                    ; The result of the evaluation
    result-type               ; "normal", "error" or "unset"
    error                     ; set if error occured
  ][
    ;; initialisations
    timestamp: none
    start: none
    end: none
    run-time: none
    result: none
    result-type: copy "normal"
    error: none
    ;; evaluate the code
    timestamp: test-now
    start: test-now/precise
    if error? set/any 'result try code-block [
      ;; catch errors in the evaluation of the code block
      result: disarm result
      result-type: copy "error"
    ]
    end: test-now/precise
    if all [
      :result-type <> "error"
      error? set/any 'result try [:result]
    ][
      result: none
      result-type: copy "unset"
    ]

    run-time: difference end start
    
    ;; create and return the output
    reduce [
      'code-block :code-block 'timestamp :timestamp
      'run-time :run-time 'result :result 'result-type :result-type
    ]
  
  ] ;; end of evaluate function
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;; evaluate-case ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  evaluate-case: func [
    { 
      Evaluates a single test case presented in the following dialect:
            name "test identifer"
  	        opt setup [setup code]
            do [the code being tested - this will be timed]
            some assert-XXXXX [assertions to check the result]
            opt teardown [teardown code]
    }
	  the-test [block!]
  ][
    eval-case/init
    eval-case/test-result/case: copy/deep :the-test
    either parse :the-test :eval-case/rules [
      get in eval-case 'test-result
    ][
      reduce [
        'status "Invalid test case"
        'case :the-test
      ]
    ]
	  
  ] ;; end of evaluate-case
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;; evaluate-set function  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  evaluate-set: func [
  	{ Evaluates a set of tests }
	  test-set [block!]             ; Format: [command [attributes]]
  ][
    either parse test-set eval-set/rules [
      final-tests: add final-tests eval-set/no-tests
      final-passed: add final-passed eval-set/passes
      final-failed: add final-failed eval-set/failures
      reduce [
        'name eval-set/name
        'tests eval-set/no-tests
        'passed eval-set/passes
        'failed eval-set/failures
      ]
    ][
      test-print "Test halted - syntax error"
      false
    ]
    
    
  ] ;; end of evaluate-set
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;;;;;;;;;;;;;;;;;; init-final-totals function  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  init-final-totals: does [
    final-tests: 0
	  final-passed: 0
	  final-failed: 0
  ] ;; end of init-final-totals
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;;;; print-final-totals function  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print-final-totals: does[
    test-print ""
    test-print join "Overall Tests " final-tests
	  test-print join "       Passed " final-passed
	  test-print join "       Failed " final-failed
  ] ;; end of print-final-totals
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;; run-tests function  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  run-tests: func [
  	{ Runs tests - either a set or suite of tests using recursion }
	  tests [file!]
  ][
    test-data: load tests
    either equal? 'suite first test-data [
      foreach suite-or-set second test-data [
        run-tests suite-or-set
      ]
    ][
      simple-test/evaluate-set test-data
    ] 
  ] ;; end of run-tests
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

] ;; end of test context!

run-test: func [
  { A wrapper for tests/run-tests in the global context }
  tests [file!]
][
  simple-test/init-final-totals
  simple-test/run-tests tests
  simple-test/print-final-totals
  exit
]
