REBOL [
    title: "(R)EBOL (Un)it"
    date: 14-apr-06
    file: %run.r
    Author: "Christophe 'REBOLtof' Coussement"
    Email: "reboltof-at-yahoo-dot-com"
	purpose: {
        RUn is a TestCase Framework wich allows the use of
        TestCases as defined by the eXtreme Programming
        development methodology and the test-driven development
    }    
	usage: {
        Background information can be found into
        eXtreme Programming method.
        
        >> do %run.r
        
        1. Submitted test file can be Unit or Suite
            >> run-test %unit-1.test
            >> run-test %suite-1.test
        2. Output can be optionaly logged
            >> run-test/log %test_suite.test
        3. A TestCase file contains:
            - optionaly a Setup function
            - one or more Developper Tests function(s)
            - optionaly a Teardown function
        4. Each Developer Test can use one of the following 
            test-functions:
            - assert (logic!)
            - assert-equal (any-value! any-value!)
            - assert-not-equal (any-value! any-value!)
            - assert-error (block!)
        5. A TestSuite contains:
            One block! named 'test-suite and containing the 
            TestCase files names or/and TestSuite file names            
    }
	history: [  
        1.9.2 [14-mar-06 "cleanup for publishing" "cou"]
        1.8.2 [27-mar-05 "add 'assert-error" "cou"]
        1.7.2 [20-oct-04 {- 'pf_assert can take any-type! for evaluation
                          - add 'pf_assert_not_equal (suggested by fvzn} "cou"]
        1.6.2 [07-oct-04 {add /only ref to 'assert-equal} "cou"]
        1.5.2 [20-sep-04 {- 'display made public (request from Coccinelle)
                          - asserting object! into object! would fail => fixed
                            (thanks again Coccinelle)
                          - force the use of a %.test file (thanks Johnatemps)} "cou"]
        1.4.2 [16-sep-04 {- assert-equal make object! [a: 1] make object! [a: 1] would fail ==> fixed
                          (Thanks to Coccinelle, for reporting the bug)
                          - code documentation compatible with RDocGen} "cou"]
        1.3.2 [08-sep-04 {assert-equal [1 2 3] [1 2] would pass ==> fixed
                          (Thanks to Coccinelle, for reporting the bug)} "cou"]
        1.2.2 [03-sep-04 {- append quiet mode (as suggested by Johnatemps) 
                          - reformat error message (as suggested by Coccinelle)} "cou"]
        1.1.2 [02-sep-04 {- assert-equal [1 2 3] [] would pass ==> fixed
                          - assert-equal [1] [[1]] triggers error ==> fixed
                          Thanks to Coccinelle, for reporting the bug} "cou"]
        1.0.2 [30-aug-04 "first public release" "cou"]
        0.3.2 [10-may-04 { Thanks to Philippe LEGOFF's feedback:
                           - modify test report layout
                           - function name where error happened is 
                             now displayed in error report
                           - log file name composed based on test 
                             file name} "COU"]
        0.2.2 [22-apr-04 "add recurrent comparison of blocks" "COU"]
        0.1.2 [07-apr-04 "Beta 1" "COU"]
		0.1.0 [05-apr-04 "History begins" "COU"]
	]
	uses: 'face	
    library: [
        level: 'advanced 
        platform: all 
        type: [tool] 
        domain: 'testing 
        tested-under: [View 1.3.2.3.1 on "Windows XP"] 
        support: "Contact the author" 
        license: 'lgpl 
    ]
]

RUn_ctx: context [
    
    ;--- init private vars    
    prl_log: false ;==> flag for logging test reports
;    ;--- header to display
    prs_header: {  
   ==================
   = (R)EBOL-(Un)it =
   = Test Framework =
   =     v.1.9      =
   ==================
      
== OUTPUT ===============================================         
}
    ;--- end test report header
    prs_report: { 
== TEST REPORT ==========================================
}
    ;--- end test footer
    prs_footer: { 
=========================================================

End of test
}

    ;===========================================================================       
    ;--- assert functions
    pf_assert: func [
    	{@ xUnit Assert function. Display if submitted condition passes
         @RETURN TRUE or FALSE}
    	 al_condition [any-type!] "condition to evaluate" ;[1.7]
    	 /local lerr_result ll_result
    ][  
        ;--- start chronometer  	
        prtime_duration: now/time/precise - prtime_start
        
        ;--- evaluate condition and feedback
        either not al_condition [
            pri_failure_count: pri_failure_count + 1
            pf_display rejoin [tab tab "*-> Assertion Failed"]
            return false
        ][
            if not prl_quiet [pf_display rejoin [tab tab "--> Passed in <" prtime_duration ">"]] ;[1.2]
            return true
        ]
    ]
    
    ;===========================================================================
    
    pf_assert_equal: func [
    	{@ xUnit AssertEqual Function. Display if or not the two args are of the same value and type.
         @RETURN true or false}
    	 aany_current [any-type!] "current result of evaluation"
         aany_expected [any-type!] "expected result of evaluation"
         /only "place of the element does not matter" ;[1.7]
    	 /local lerr_result 
    ][    	
        ;--- start chronometer  	
        prtime_duration: now/time/precise - prtime_start
        
        ;--- set order matter
        prl_sorted: only ;[1.7]
        
        ;--- if object! set argument on third object! and handle it
        ;- as being block!
        if all [ ;[1.4]
            object? aany_current
            object? aany_expected
        ][
            aany_current: third aany_current
            aany_expected: third aany_expected
        ]
        
        ;--- if the current and expected data are a block, we're going to compare
        ;- each sub-block one by one in a recursive way
        either all [
            block? aany_expected 
            block? aany_current
        ][
            either prf_assert_block_equal aany_current aany_expected [
                if not prl_quiet [pf_display rejoin [tab tab "--> Passed in <" prtime_duration ">"]] ;[1.2]
                return true
            ][                
                pri_failure_count: pri_failure_count + 1
                pf_display rejoin [tab tab "*-> Assertion Failed"]
                return false
            ]
        ][
            ;--- evaluate comparison and feedback            
            either not aany_current == aany_expected [
                pri_failure_count: pri_failure_count + 1
    		    pf_display rejoin [
                    tab tab "*-> Data expected: " mold aany_expected " of type: [" type? aany_expected "!]^/"
                    tab tab "    but was : " mold aany_current " of type: [" type? aany_current "!]"
                ]                
                return false
    		][
                if not prl_quiet [pf_display rejoin [tab tab "--> Passed in <" prtime_duration ">"]] ;[1.2]
                return true
            ]
        ]        
    ]
    
    pf_assert_not_equal: func [
    	{@ xUnit AssertNotEqual Function. Display if or not the two args are NOT 
         @ of the same value and type.
         @RETURN true or false}
    	 aany_current [any-type!] "current result of evaluation"
         aany_expected [any-type!] "expected result of evaluation"
         /only "place of the element does not matter" 
    	 /local lerr_result 
    ][
        return not either only [
            pf_assert_equal/only aany_current aany_expected
        ][
            pf_assert_equal aany_current aany_expected
        ]
    ]
    
    pf_assert_error: func [ ;[1.8]
    	{@ Display if error is triggered 
         @RETURN true or false}
    	 ab_code [block!] "block to evaluate"
         /type-id "Specify the type-id of the error" 
            ab_type-id "Type-ID of the error"
    	 /local lerr_result 
    ][
        either error? lerr_result: try ab_code [
            lerr_result: disarm lerr_result
            either type-id [
                answer: all [
                    lerr_result/type = ab_type-id/1
                    lerr_result/id =  ab_type-id/2
                ]
            ] [
                answer: true
            ]
        ] [
            answer: false
        ]
        return pf_assert answer
    ]
    
    ;===========================================================================
        
    prf_assert_block_equal: func [ ;[0.2]
    	{@ compare the inside of two blocks 
    	 @RETURN true or false}
    	 ab_current [block!] "current block of evaluation"
         ab_expected [block!] "expected block of evaluation"
    	 /local lerr_result lb_current
    ][
        if prl_sorted [sort ab_current sort ab_expected] ;[1.6]
        
        ;--- get clean copy for ref
        lb_current: copy ab_current
        ;--- if one of block is empty, then other must be too
        ;- otherwise, test fails. It fails too if the blocks
        ;- are not of the same length
        if (length? ab_current) <> (length? ab_expected) [ ;[1.1][1.3]
            pf_display rejoin [
                tab tab "*-> Block! of length : " length? ab_expected " was expected^/"
                tab tab "    but was block! of length : " length? ab_current " was provided !]"
            ] 
            return false
        ]
        
        foreach eany_expected ab_expected [
        
            ;--- if the two members are objects, convert them to block!
            if all [ ;[1.5]
                object? eany_expected 
                object? lb_current/1
            ][
                eany_expected: third eany_expected
                lb_current/1: third lb_current/1
            ]
            
            either all [block? eany_expected block? lb_current/1][ ;[1.1]
                ;--- if we find a block here, we have to recurent call the func
                ;- if it fails (return false), the failure will be transmitted 
                ;- to the first level of recursion
                
                if not prf_assert_block_equal lb_current/1 eany_expected [
    	            return false
    	        ]
    	    ][
                ;--- if word is 'none is we have to re-give a meaning to it
                ;- because it is known as word (not bound to the same context)
                ;- (perhaps is there a more elegant way to solve this ?)
                if 'none = eany_expected [eany_expected: none]
                
                ;--- compare each found values.
                ;- comparison stops when the first difference is found
    	        if not lb_current/1 == eany_expected [
                    pf_display rejoin [
                        tab tab "*-> Data expected into block : " mold eany_expected " of type: [" type? eany_expected "!]^/"
                        tab tab "    but was : " mold lb_current/1 " of type: [" type? lb_current/1 "!]"
                    ]                
                    return false
        		]
    	    ]
            
            ;--- go one position further into current block
            lb_current: next lb_current            
    	]
        return true
    ]
    
    
    ;===========================================================================
       
    pf_display: func [
    	{@ Display any message, rejoining block! if provided. Should be GUI in a next release.
         @RETURN none}
    	 aany_msg [string! block!] "msg to display"
    	 /local lerr_result 
    ][    	
    	;--- display message.
        ;- some VID layout could be used here
    	print either block? aany_msg [rejoin aany_msg][aany_msg]   
        
        ;--- if we want to log, check log file existance and log
        ;- msg into it	
        if prl_log [
            if not exists? prfile_log [
                write prfile_log ""
            ]
            write/append prfile_log either block? aany_msg [rejoin aany_msg][aany_msg]
            write/append prfile_log newline
        ]
    ]
            
    ;===========================================================================
       
    prf_error: func [
    	{@ handle test error by displaying the disarmed value
    	 @RETURN none}
    	 aerr_data [error!] "error to handle"
         as_func_name [string!] "func name where error happened" 
    	 /local lerr_result lo_error
    ][
        ;--- make error useful
    	lo_error: disarm aerr_data
        lw_type: lo_error/type ;[1.2]
        li_id: lo_error/id ;[1.2]
        ls_msg: rejoin [ ;[1.2]
            system/error/:lw_type/type ": "
            system/error/:lw_type/:li_id
        ]
        attempt [replace ls_msg "arg1" form lo_error/arg1] ;[1.2]
        attempt [replace ls_msg "arg2" form lo_error/arg2]
        attempt [replace ls_msg "arg3" form lo_error/arg3]
        pri_error_count: pri_error_count + 1
        
        ;--- disply error
        pf_display rejoin [
            tab tab "!-> ERROR generated:" newline
            tab tab tab ls_msg newline ;[1.2]
            tab tab tab "Near : " copy/part mold/only lo_error/near 100 newline ;[1.2]   
            tab tab tab "Where: " as_func_name newline ;[0.3]     
        ]         
    ]    
    
    ;===========================================================================
    ;--- Run test functions
    pf_run_test: func [
         {@ handle submitted TestCase or TestSuite file.
    	  @RETURN none}
    	 afile_test [file!] "file to handle"
         /log "write down all output from console"
         /quiet "output only for failed tests"
    	 /local lerr_result lo_test
    ][
        ;--- force the use of %.test suffix
        if not find afile_test %.test [ ;[1.5]
            print [
                "***" afile_test "is not a test file !" newline
                "*** Please provide a valid file name."
            ]
            ask "Press [Enter] to quit" 
            quit
        ]
        
        ;--- 'log option
        if log [
            ;--- activate log
            prl_log: true
            ;--- set log file name
            prfile_log: replace copy afile_test %.test %-TestReport.log ;[0.3]
        ]
        prl_quiet: quiet
        ;--- set some private vars
        prb_func: copy [] ;==> container for tests functions names
        pri_test_count: pri_error_count: pri_failure_count: 0 ;==> counters
        prtime_duration: prtime_start: 0:0 ;==> chronometer
            
        ;--- display RUn header
	    pf_display prs_header      
        if log [pf_display form now]
        
        ;--- branch test to TestCase or TestSuite
        ;- allowing recurent call
        prf_branch_test afile_test
        
        ;--- display test results
        pf_display prs_report
        pf_display [ ;[0.3]
            " TOTAL : " pri_test_count newline
            "    => Passed   : " pri_test_count - pri_failure_count - pri_error_count newline
            "    => Failures : " pri_failure_count newline
            "    => Errors   : " pri_error_count 
        ]
        
        ;--- display footer
        pf_display prs_footer
        ask "Press [ENTER] to Quit"
    ]    
    
    ;===========================================================================
    
    prf_branch_test: func [
    	{@ If submitted file contains a TestSuite file, this func will
         @ make a recurent call until a TestCase file is found. If it 
         @ contains a TestCase, it will run each test.
    	 @RETURN none}
    	 afile_test [file!] "file to branch"
    	 /local lerr_result 
    ][
        ;--- convert test file into object for easier access
        lo_test: make object! load afile_test  
        
    	;--- if there is a 'test-suite defined into object's context
        ;- then where dealing with a Suite of Tests
		either find first lo_test 'test-suite [
            ;--- Suite of Tests: handle test file one at the time
		    foreach efile_test lo_test/test-suite [
                prf_branch_test efile_test
		    ]
		][
            ;--- no Suite of Tests: handle single test file, allowing recurrent call
		    prf_run_unit_test afile_test
		]
    ]
        
    ;===========================================================================
    
    prf_run_unit_test: func [
    	{@ Run Developer Tests found into provided file.
    	 @RETURN none}
    	 afile_test [file!] "file to handle"
    	 /local lerr_result lo_test ll_setup? prl_teardown?
    ][
        ;--- convert single test into object for easier access
        ;- and creation of execution context
    	lo_test: make object! load afile_test

        ;--- check presence of setup and teardown func    
        ll_setup?: if find first lo_test 'setup [true][false]
        ll_teardown?: if find first lo_test 'teardown [true][false] 
        
        ;--- display test file name      
        pf_display [newline "> " afile_test]
        
        ;--- execute setup if exists, if needed, handle error
        if ll_setup? [
            if not prl_quiet [pf_display [newline "    >> SETUP"]] ;[1.2]
            either error? set/any 'lerr_result try [
                lo_test/setup
            ][
                prf_error lerr_result "Setup"
            ][
                if not prl_quiet [pf_display [tab tab "--> Done"]] ;[1.2]
            ]
        ]        
        
        ;--- execute all tests found
        foreach ew_func_name first lo_test [
            if all [
                ew_func_name <> 'teardown
                ew_func_name <> 'setup
                ew_func_name <> 'self            
            ][
                if not prl_quiet [pf_display ["    >> " :ew_func_name]] ;[1.2]
                pri_test_count: pri_test_count + 1
                ;--- execute single test and , if needed, handle error
                if error? set/any 'lerr_result try [
                    prtime_start: now/time/precise
                    if all [ ;[1.2]
                        not lo_test/:ew_func_name
                        prl_quiet
                    ][
                        pf_display ["            [in " :ew_func_name "]"]
                    ]
                ][
                    prf_error lerr_result form ew_func_name
                ]
            ]
        ]
        
        ;--- execute teardown if exists
        if ll_teardown? [
            if not prl_quiet [pf_display [newline "    >> TEARDOWN"]] ;[1.2]
            either error? set/any 'lerr_result try [
                lo_test/teardown
            ][
                prf_error lerr_result "Teardown"
            ][
                if not prl_quiet [pf_display [tab tab "--> Done"]] ;[1.2]
            ]
        ]
    ]
    
    ;===========================================================================
    
    ;--- set to public interface using 'rebolian' wording:
    prl_quiet: false
    set 'assert :pf_assert
    set 'assert-equal :pf_assert_equal
    set 'assert-not-equal :pf_assert_not_equal
    set 'assert-error :pf_assert_error ;[1.8]
    set 'run-test :pf_run_test      
    set 'display :pf_display  ;[1.5]
]