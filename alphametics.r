REBOL [
	File: %alphametics.r
	Date: 1-feb-2005
	Title: "Solve alphametic equations"
	Version: 0.0.1
	Author: "Sunanda"
	Purpose: {Solve alphametic equations like "send+more=money"}

 	Library: [
 	         level: 'intermediate
 	      platform: [all plugin]
 	          type: [game demo fun]
 	        domain: [math]
 	  tested-under: [win]
 	       support: none
 	       license: 'bsd
 	        plugin: [size: 460x600]

 	]
]


;; ==========================================
;; For documentation see:
;;     http://www.rebol.org/cgi-bin/cgiwrap/rebol/documentation.r?script=alphametics.r
;;
;; Script consists of two objects:
;;
;; sa       --  provides the solving engine
;; sa-view  --  provides the VID interface
;;
;; To run VID interface
;;
;;    sa-view/display-panel
;;
;; To run from command line (examples)
;;
;;     sa/solve "send+more=money"
;;     sa/solve/constraints "send+more=money" [s=9 m=1 o=0]
;;     sa/solve/base "w*y*z=(xx.x*10)" 16  ;; 50 solutions



sa-view: make object!
 [

   ;; -----------------------------
   ;; sa-view: REBOL/View functions
   ;; -----------------------------


;; =========================================
;;   variables used in VID interface
;; =========================================
      sa-panel: none
      equation: none
      progress: none
   constraints: none
        answer: none
solutions-list: none
       solving: false
          base: none
        cancel: none
       err-obj: none
        result: none
      help-url: http://www.rebol.org/cgi-bin/cgiwrap/rebol/documentation.r?script=alphametic.r
 help-url-full: none

;; =========================================

 sa-callback: func [solution [object!]
   /local
 ][
  if sa-view/cancel [return false]   ;; stop the show
  progress/text: join "cases tried: " solution/cases
  show progress

  if solution/solution-found?
     [append solutions-list solution/equation
      answer/text: copy ""
      foreach sol sort solutions-list
         [append answer/text sol
          append answer/text newline
         ]
      show answer
     ]

  wait 0.01     ;; to let the cancel button have a chance
  return true

 ]

;; ==========================================

display-panel: func [
  /local
][
  unview/all
  view sa-panel: layout
     [across
      banner "solve an alphametic"
      return
      label 100 right "equation:"
      equation: field 200x50
      return
      label 300 right "base:"
      base: rotary "10" "11" "12" "13" "14" "15" "16"
                    "2" "3" "4" "5" "6" "7" "8" "9"
      return
      label 100 right "constraints, if any"
      constraints: field 200x50
      return
      button "solve!"
        [if solving [exit] ;; pressing the solve! button repeatedly
                           ;; will start multiple instances, and that
                           ;; will soon crash View. This should stop that.
         solving: true
         cancel: false
         solutions-list: copy []
         answer/text: copy "[working....]"
         progress/text: copy "_"
         show answer
         show progress
         if error? err-obj: try
            [
             cons: copy []
             foreach c parse constraints/text " " [append cons c]
              result: sa/solve/safe/callback/tick/constraints/base equation/text :sa-callback 0:0:0.25 cons to-integer base/text
              progress/text: join "solutions: " result/1
              if not result/2 [append progress/text " ... cancelled before completion"]
              if answer/text = "[working....]"
                  [
                   answer/text: copy ""
                   show answer
                  ]
              show progress
              solving: false
              true    ;; to return a value for the try
            ]
           [
            progress/text: get in disarm err-obj 'arg1
            solving: false
            show progress
            exit
           ]
        ]
      return
      label 100 right "solutions:"
      answer:   info 200x300 white font-color blue
      button "cancel" [cancel: true return true]
      return
      progress: info 300x50 white blue wrap


      button "web help"     ;; If we have an error message on show, go to that
                            ;; part of the document, otherwise, just to the
                            ;; start
          [if error? try
             [
              either all ["[sa-" = copy/part progress/text 4
                          "]" = form progress/text/7
                         ]
                    [browse help-url-full: join help-url ["#"  first parse next progress/text "]"] exit]
                    [browse help-url-full: help-url exit]
             ]
             [
              progress/text: join "Sorry -- can't access help at " help-url-full
              show progress
             ]
          exit
         ] ;; web help action
     ] ;; layout
 return true
] ;; func


] ;; sa-view object


;; ===============================================
;; ===============================================
;; ===============================================




sa: make object!
 [

   ;; ------------------------
   ;; sa: REBOL/Core functions
   ;; ------------------------


 ;; ==========
 ;; Data areas
 ;; ==========

 mo: none                ;; main working object

 solve-func: none           ;; will be a function to solve the puzzle

 callback-parms: make object!
   [
    solution-found?: true
    solution-number: 0
              cases: 0
           equation: ""
           solution: copy []
   ]


  ;; =========
  ;; Functions
  ;; =========

solve: func [
    p-equation                   [string!]
   /base        p-base         [integer!]
   /constraints p-cons           [block!]
   /callback    p-callback    [function!]
   /tick        p-tick   [time! integer!]
   /safe
   /debug
][
 mo: none         ;; reset any previous values
 validate-parameters p-equation p-base p-cons :p-callback p-tick
 setup-search

 preapply-constraints


 if 0 <> length? mo/constraints
    [
     apply-constraints

     refine-constraints
     validate-constraints
    ]

 if safe [mo/safe: true]

 renormalise-equation
 solve-func: none
 solve-func: generate-solve-function

 if debug [show-debug-info]

 catch [solve-func]


 return reduce [mo/solutions-found not mo/cancelled]
] ;; solve



;; ========================================================
;; validates parameters and creates the mo object
;; that contains the structures the solvers need
;; ========================================================
validate-parameters: func [
    p-equation              [string!]
    p-base           [none! integer!]
    p-cons             [none! block!]
    p-callback      [none! function!]
    p-tick     [none! time! integer!]
  /local
   operators
][
 mo: make object!
     [
     equation:    copy p-equation
     base:        p-base
     variables:     copy ""

     digits: none
     quick-digits: none

     words:  copy []            ;; unique list of words in alphametic

     constraints: copy []
     safe: false

     normalised-equation: none

     digits-range: copy []
     solution: copy []             ;; current solution

     solutions-found: 0
     solutions-considered: 0


     callback-function: none      ;; actual function for callback
     callback?: false             ;; true/false if callback is enabled
     tick: copy [0 0]
     cancelled: false             ;; callback say stop
     ]

 if none? mo/base [mo/base: 10]
 if any [mo/base < 2 mo/base > 36]
     [make error! "[sa-01] /base should be between 2 and 36"]

 if (length? p-equation) <> length? join "=" replace/all copy p-equation "=" ""
     [make error! ["[sa-02] equation should have one (and only one) equals sign"]]

;; --------------------------
;; set the report back fields
;; --------------------------

 mo/callback-function: :p-callback
 if function? :p-callback [mo/callback?: true]
 if all [function? :p-callback not none? p-tick]
   [
    either time? p-tick
        [
         mo/tick/2: max 0:0:0.1 p-tick           ;; call interval
         mo/tick/1: now/precise + mo/tick/2      ;; time of next call
        ]
        [
         mo/tick/2: max 1 p-tick                  ;; call frequency
         mo/tick/1: 0                             ;; count of calls
        ]
   ]


 if block? p-cons [mo/constraints: copy p-cons]

 ;; ------------------------------
 ;; Make sure the equation is both
 ;; REBOL-compliant as maths, and
 ;; contains an appropriate number
 ;; of variables for the base in
 ;; question
 ;; -------------------------------

 operators: ["+"    " + "
             "-"    " - "      ;; doesn't really work for some unary minuses
             "/"    " / "
             "*"    " * "
             "("    " ("
             ")"    ") "
             "="    " = "
             "*  *" "**"     ;; correct for power series
             "/  /"  "//"    ;; ditto for modular division
             ]


 mo/digits: copy/part "0123456789abcdefghijklmnopqrstuvwxyz" mo/base

 mo/quick-digits: copy []
 for nn 1 mo/base 1 [append mo/quick-digits nn - 1]

 mo/variables: trim/all sort unique lowercase copy p-equation
 foreach [operator x] operators
    [replace mo/variables operator ""]

 foreach digit join  mo/digits "." [replace mo/variables digit ""]

 if (length? mo/variables) > mo/base
     [make error! "[sa-03] equation has too many variables for the digit base"]


 if 0 = length? mo/variables
     [make error! "[sa-04] equation has no variables"]

 mo/normalised-equation: trim/lines copy p-equation
 foreach [operator rebolised-operator] operators
   [replace/all mo/normalised-equation operator rebolised-operator]
 trim/lines mo/normalised-equation



;; Produce word list
;; -----------------
;; so (say):
;; equation: "send+2*(more+and+more+and+more)=money"
;; is these words:
;;    words: ["2" "and" "more" "money" "send"]
;; Will be used to normalise for different bases,
;; and to add constraints to eliminate leading zeroes


 mo/words:  copy mo/equation
 foreach [operator xx] operators
   [replace/all mo/words operator " "]

 mo/words: unique parse mo/words " "
 sort/compare mo/words func [a b] [return (length? a) > length? b]

 return true
]


;; ===========================================
renormalise-equation: func [
 /local
][

 if mo/base = 10 [return true]

;; Renormalise for base other than 10
;; ----------------------------------
;;



 for nn 1 length? mo/words 1
  [
   error? try [unset to-word mo/words/:nn]
   replace/all mo/normalised-equation mo/words/:nn join "!" to-char nn
  ]


 for nn 1 length?  mo/words 1
   [
    replace/all mo/normalised-equation join "!" to-char nn renormalise-word mo/words/:nn
   ]

 return true
]




;; =======================================
renormalise-word: func [
    word [string!]
  /local
   positions
   power
   digits-range
   constants
   variables
   normalised-word
;; -----------------------------------------
;; We got a word like "sit" in base-16. We
;; want to return it so that normal base-10
;; arithmetic will work:
;;
;; ((s * 256) + (i * 16) + t)
;;
;; And we want to throw in a few optimisations
;; too -- maybe the word was "cat" in base-16:
;; c and a are digits not variables, so
;;
;; ((c * 256) + (a * 16) + t)
;; is
;; ((12 * 256)) + (10 * 16) + t)
;; which simplifies to:
;;
;; (3262 + t)
;;
;; Similarly, if we know from constraints
;; that t can only be e, we can make it
;; (3262 + 14)
;; or just
;; 3676
;;
;; We also need to handle places after the
;; base=point:
;;
;; si.t in base-16 is
;; (s * 16) + i + ( t *.0.625)
;; -----------------------------------------

][
 positions: copy []
 power: mo/base ** length? first parse word "."
 foreach var word
  [
   var: to-string var
   either var = "."
     [power: 1]     ;; switch to post-point powers
     [
       power: power / mo/base
       either error? try [var: to-base var]
            [
             digits-range: pick mo/digits-range index? find mo/variables var
             either 1 = length? digits-range
                  [append positions digits-range/1  * power ]   ;; constrained to a single value
                  [
                   either power = 1
                       [append positions var]                       ;; has multiple values
                       [append positions join var [" * " power]]    ;; has multiple values
                  ]
            ]
            [append positions var * power]  ;; it's a digit, like 1 or A (in bases above 10)
     ] ;;either "."
  ] ;; for


;; positions now has something like:
;; [1280 "s * 16"  "t" "0.0625"]
;; We can simplify this to the final
;; expression of
;; "(1280.0625 + (s * 16) + t)"

 constants: 0
 variables: copy []
 foreach position positions
   [
    if error? try [constants: constants + do position]
       [
        either find position " "
            [append variables join "(" [position ")"]]  ;; something like (256 * y)
            [append variables position]                 ;; something like just y
       ];; if
   ] ;; for

 if 0 = length? variables [return constants]

 normalised-word: copy ""
 foreach var variables
    [
     append normalised-word join form var " + "
    ]
 normalised-word: copy/part normalised-word -3 + length? normalised-word
 if constants <> 0 [insert normalised-word join form constants " + "]

 either find normalised-word "+"
     [return join "(" [normalised-word ")"]]
     [return normalised-word]

]




;; =======================================
setup-search: func [
 /local
  entry
][


for nn 1 length? mo/variables 1
  [
   entry: copy []
   for nn 1 length? mo/digits 1 [append entry nn - 1]
   append/only mo/digits-range entry
  ]
]




;; ==================================================
preapply-constraints: func [
  /local
   initial-letter
  ][
;; ----------------------------------
;; If we have something like
;; "send+more=money" then we
;; know that s~0 and m~0.
;; By adding them to the constraints,
;; we make our search faster.
;;
;; In fact, we insert them before
;; any user-supplied constraints.
;; That way, they can override
;; use if the want.
;; eg despite what we do here,
;; a user constraint of
;; [m=01] will allow solutions
;; that have a leading 0 for m.

 foreach word mo/words
   [
    initial-letter: form word/1

    if all [not find join mo/digits "." initial-letter
            initial-letter <> "~"      ;; can't handle a tilde as a variable
           ]
         [
          insert mo/constraints join initial-letter ["~0"]
         ]
  ] ;; for

 return true
]




;; ==================================================
apply-constraints: func [
  /local
   variables-affected
   copy-constraint
][

 foreach constraint mo/constraints
   [
    constraint: to-string constraint
    copy-constraint: copy constraint

    either find [#"~" #"="] constraint/1
       [variables-affected: copy mo/variables]
       [
        variables-affected: to-string constraint/1
        constraint: next constraint
        ]
    apply-this-constraint copy-constraint variables-affected constraint
    if error? try [apply-this-constraint copy-constraint variables-affected constraint]
       [
        make error! join "[sa-10] unrecognised digit in this constraint:  " copy-constraint
       ]
   ] ;; for


;; Now check what results makes sense
;; ----------------------------------

 for nn 1 length? mo/variables 1
   [
    if 0 = length? mo/digits-range/:nn
       [
        make error! join
                    "[sa-08] /constraints have left no possible value for variable "
                     mo/variables/:nn
       ]

    foreach digit mo/digits-range/:nn
       [
        if digit > mo/base
         [
          make error! join    ;; Can this ever happen!?
                    "[sa-??] /constraints have set variable "
                    [mo/variables/:nn
                     " to "
                      digit
                      ". That is not an acceptable digit in base "
                      mo/base
                     ]
          ] ;;if
       ] ;; for
   ] ;; for

 return true
]





;; ===========================================
apply-this-constraint: func [
      original-constraint [string!]   ;; for error messages only
      variables-affected  [string!]
              constraint  [string!]
 /local
  type
  index
][

 if not find [#"~" #"="] constraint/1
    [make error! join "[sa-06] unrecognised constraint -- " original-constraint]

 type: to-string constraint/1

 foreach variable variables-affected
    [
     index: find mo/variables variable
     if none? index
        [
         make error! join "[sa-07] constraint given for unknown variable -- "
                          [ original-constraint "-- " variable]
        ]
     index: index? index
     either type = "~"
           ;; remove digits
           ;; -------------
           [
            foreach digit next constraint
                [
                 digit: to-base load form digit
                 if find mo/digits-range/:index  digit
                       [alter mo/digits-range/:index digit]
                ]
           ]
           ;; must be "=" -- set to specific digits
           ;; -------------------------------------
           [
            clear mo/digits-range/:index
            foreach digit next constraint
                [
                 digit: to-base digit
                 if not find mo/digits-range/:index  digit
                       [alter mo/digits-range/:index digit]
                ]
           sort mo/digits-range/:index
           ]

    ] ;; for
 return true
]




;; ===========================================
refine-constraints: func [
  /local
   changes-made
][
;; -------------------------------
;; If we had something like
;; a=1 then we now know
;; that no one else can be 1.
;; By removing that possibility,
;; from all others, we'll reduce
;; the total searches needed a lot
;; --------------------------------
;; That may lead to some impossible
;; situations .....eg
;; Example: if we have this situation in
;; base 5 [so only 0 1 2 3 4 are
;; the digits in use]
;; a=123
;; b=1
;; c=2
;; d=3
;; Suddenly a has no possible values!

 changes-made: -999
 while [changes-made <> 0]
   [
    sort-variables
    if 1 <> length? mo/digits-range/1 [break]
    changes-made: 0
    for nn 1 (-1 + length? mo/digits-range) 1
       [
        for mm (nn + 1) length? mo/digits-range 1
           [
            if 1 = length? mo/digits-range/:nn
               [
                if find mo/digits-range/:mm mo/digits-range/:nn/1
                   [
                    changes-made: changes-made + 1
                    alter mo/digits-range/:mm mo/digits-range/:nn/1
                   ] ;; if
               ] ;; if
           ] ;; for
       ] ;; for
   ] ;; while

 sort-variables
 if 0 = length? mo/digits-range/1
   [
    make error! join "[sa08] constraints have left no possible value for variable " mo/variables/1
   ]
 return true
]




;; ===========================================
validate-constraints: func [
  /local
   total-digits
][
;; ------------------------------------
;; A courtesy check before we spend the
;; next half-an-hour failing to solve
;; an insoluble alphametic.
;; ------------------------------------
;; Example:
;; "aaa+bbb+ccc=ddd" [=123]
;;  a,b,c,d are constrained to 1,2,3: not enough digits!

 total-digits: copy []
 foreach range mo/digits-range [append total-digits range]
 if (length? unique total-digits) < length? mo/variables
    [
     make error! "[sa-09] too few digits left for the variables"
    ]

 return true
]




;; ==========================================

sort-variables: func [
 /local
  work-block
  entry
][
;; ---------------------------------------
;; constraints may have caused variables to
;; have different numbers of possibilities,
;; eg:
;; a: [1 2 3]
;; b: [1 2 3 4 5]
;; c: [9]
;;
;; By applying them most-constrained first,
;; we'll do a pile less work
;; when brute-force searching the solutions
;;
 work-block: copy []
 for nn 1 length? mo/variables 1
    [
     append work-block length? mo/digits-range/:nn
     append work-block form mo/variables/:nn
     append/only work-block mo/digits-range/:nn
    ]


 sort/skip work-block 3

 mo/variables: copy ""
 mo/digits-range: copy []

 foreach [length var var-range] work-block
  [
   append mo/variables var
   append/only mo/digits-range var-range
  ]

 return true

]




;; ===============================================
;; generate solutions is left in an courtesy. It's
;; the original way the scrip solved the equation:
;; using  recursion  to   generate  all  the valid
;; arrangements of the variable's values.
;; Later,  faster versions,  generate  a  specific
;; function first, and run that instead.
;; ==============================================

generate-solutions: func [
       n-var   [integer!]
      digits     [block!]
    equation    [string!]
  /local
   valid-digits
   copy-equation
][
 if n-var > length? mo/variables
     [check-for-solution digits equation
      return true
     ]

 foreach digit exclude mo/digits-range/:n-var digits
   [
    copy-equation: copy equation
    replace/all copy-equation mo/variables/:n-var digit
    generate-solutions n-var + 1 join digits digit copy-equation
   ]
 return true

]




;; ==============================================
check-for-solution: func [digits [block!] eq [string!]
  /local
][

;; ----------------------------------------------
;; same as check-for-solution-with-callback-tick,
;; except it doesn't check if callback ticks are
;; in effect -- so runs much faster
;; ----------------------------------------------

 if do eq
   [ mo/solution: digits
    report-solution eq digits
    return true
   ]
]




;; ==============================================
check-for-solution-with-callback-tick: func [digits [block!] eq [string!]
  /local
][


 if do eq
   [
    mo/solution: digits
    report-solution eq digits
    return true
    ]


;; No solution: but do we need a callback tick?
;; --------------------------------------------

 if not mo/callback?  [return true]

 either integer? mo/tick/1
    [
      mo/tick/1: mo/tick/1 + 1
      if mo/tick/1 < mo/tick/2 [return true]
      mo/tick/1: 0
    ]
    [
      if mo/tick/1 > now/precise [return true]
      mo/tick/1: now/precise + mo/tick/2
    ]


 callback-parms/solution-found?: false
 callback-parms/solution-number: mo/solutions-found
 callback-parms/cases: mo/solutions-considered
 callback-parms/equation: copy eq
 callback-parms/solution: copy []

 if not mo/callback-function callback-parms
   [
    mo/cancelled: true
    throw 'callback-exit
   ]

 return true

]




;; ===========================================================

report-solution: func [eq [string!] digits [block!]
 /local status-object
][

 mo/solutions-found: mo/solutions-found + 1

 callback-parms/solution: copy []
 for nn 1 length? mo/variables 1
     [
      append callback-parms/solution form mo/variables/:nn
      append callback-parms/solution digits/:nn
     ]
 sort/skip callback-parms/solution 2

 callback-parms/equation: copy mo/equation
 for nn 1 length? digits 1
     [
      replace/all callback-parms/equation mo/variables/:nn pick mo/digits 1 + digits/:nn
     ]

 if mo/callback?
     [
      callback-parms/solution-found?: true
      callback-parms/solution-number: mo/solutions-found
      callback-parms/cases: mo/solutions-considered

      if not mo/callback-function callback-parms
        [
         mo/cancelled: true
         throw 'callback-exit
        ]
      return true
     ]



;; default solving action: print a line
;; ------------------------------------
 print ["SOLUTION!!" mold callback-parms/solution callback-parms/equation]
 return true
]




;; ==============================================
generate-solve-function: func [
 /local
  gen-func
  iterated-code
][


;; Make function header
;; --------------------
;; we have a set on local
;; variables for each
;; variable in the equation

gen-func: copy {func [/local }
for nn 0 length? mo/variables 1
  [
    append gen-func join " eq" nn
    append gen-func join " n" nn
  ]
append gen-func " digits mo "

if mo/safe [append gen-func "err-obj "]

append gen-func " ][ "


;; Make function startup code
;; --------------------------

append gen-func
    {
 mo: sa/mo
 mo/solutions-considered: 0
 eq0: copy mo/normalised-equation
 digits: copy []
 for nn 1 length? mo/variables 1 [append digits "?"]
    }


;; Insert the loops
;; ----------------

for nn 1 length? mo/variables 1
  [
   iterated-code: copy
   {
    foreach n* exclude ## copy/part digits #
      [
       digits/*: n*
       eq*: copy eq#
       replace/all eq* mo/variables/* n*

    }
  replace/all iterated-code "##" mold mo/digits-range/:nn
  ;;  replace/all iterated-code "##" join  "mo/digits-range/" nn
       ;; commented option above not as fast as one in place

  replace/all iterated-code "*" nn
  replace/all iterated-code "#" nn - 1

  append gen-func iterated-code
  ]

;; Add the check for solution
;; ---------------------------

 append gen-func " mo/solutions-considered: mo/solutions-considered + 1 "

 if mo/safe [append gen-func "if error? err-obj: try [ "]

 either mo/tick/2 <> 0
   [append gen-func join "sa/check-for-solution-with-callback-tick digits eq" length? mo/variables]
   [append gen-func join "sa/check-for-solution digits eq" length? mo/variables]

 if mo/safe
      [
       append gen-func
   {    ][
           err-obj: disarm err-obj
           if not find [zero-divide overflow positive] err-obj/id
                  [make error! "[sa-11] problems with the equation"]  ;; pass it upwards
        ]
   }

       ]

;; close off the foreach's
;; -----------------------

loop length? mo/variables [append gen-func "]"]


;; Finish off
;; ----------

append gen-func "return true ]"

return first reduce load  gen-func


] ;; func




;; ==========================================
to-base: func [digit [char! string! number! word!]
][

;; -------------------------------------
;; Given, say "c" in base 15, returns 12
;; -------------------------------------

 if number? digit [return digit]
 if word? digit [digit: form digit]


return -1 + index? find mo/digits digit

]



;; =======================================
show-debug-info: func [
 /local
][

 print ["base:" mo/base]
 print ["equation:" mo/normalised-equation]
 print ["variables+possible values:"]
 for nn 1 length? mo/variables 1
    [
     print ["  " to-string mo/variables/:nn mold mo/digits-range/:nn]
    ]
 return true

]


] ;; sa object



;; ============================================
;; ============================================
;; ============================================

;; Show the View panel at start-up:

 sa-view/display-panel


