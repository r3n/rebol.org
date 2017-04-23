REBOL [
   file: %base-convert.r
   title: "Base conversion functions"
   author: "Sunanda"
   date: 01-sep-2005
   version: 0.0.2
   purpose: {Functions to convert an decimal whole number to and from any arbitrary base}
   library: [
           level: 'intermediate
        platform: [all plugin]
            type: [tool function]
          domain: [math scientific financial]
    tested-under: [win]
         support: none
         license: 'GPL
        see-also: none
          plugin: [size: 770x140]
     ]
   history: [
             0.0.1 1-aug-2004 {Written}
             0.0.2 1-sep-2005 {Added View/browser plugin front end}
            ]
    ]


;; ---------------------------------------------------------------------
;; This script has two objects:
;;
;; base-convert      -- REBOL/Core script that provides conversions
;; view-base-convert -- REBOL/View, REBOL/Plugin front end to play with
;;
;; If you just want to use the base-convert functions, comment
;; out the view-base-convert/run line at the very end
;; -------------------------------------------------------------------

;; --------------
;; Documentation:
;; --------------
;; see http://www.rebol.org/cgi-bin/cgiwrap/rebol/documentation.r?script=base-convert.r


;; ===================
;; base-convert object
;; ===================


base-convert: make object! [

;;  Customisable data items
;;  -----------------------
    maximum-decimal: 999999999
    default-digits: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    case-sensitive: false
    error-messages: [
        "Maximum base should be "
        "Base minimum is 2. Not "
        "Base contains duplicate characters: "
        "Number to convert must be 0 or greater"
        "Number has unrecognised digit: "
        "Number larger than "
        "Number should be a whole number (no decimal places)"
    ]

;;  ================
;;  to-base function
;;  ================

    to-base: func [number-in [number!]
        to-base [integer! string!]
        /local
         number-out
         int-part
         frac-part
    ][
        if number-in < 0 [make error! error-messages/4]  ;; too small
        if 0 <> (number-in // 1)  [make error! error-messages/7] ;; not whole number
        if number-in > maximum-decimal [make error! join error-messages/6 maximum-decimal] ;; too big
        to-base: make-base-string to-base
        number-out: copy ""
        int-part: number-in
        until
        [
            frac-part: 1 + (int-part // length? to-base)
            if frac-part > length? to-base [frac-part: 1]
            insert number-out to-base/:frac-part
            int-part: to-integer (int-part / length? to-base)
            int-part = 0
        ]
        return number-out
    ] ;; func

;;  ==================
;;  from-base function
;;  ==================
    from-base: func [number-in [string!]
        from-base [integer! string!]
        /local
         number-out
         curr-digit
    ][
        from-base: make-base-string from-base
        number-out: 0.0
        foreach digit number-in
        [   number-out: number-out * length? from-base
            either case-sensitive
            [curr-digit: find/case from-base to-string digit]
            [curr-digit: find from-base to-string digit]
            if none? curr-digit [make error! join error-messages/5 to-string digit]  ;; bad digit
            number-out: number-out - 1 + index? curr-digit
        ]
        return number-out
    ] ;; func

;;  ====================================
;;  internal function:  make base string
;;  ====================================
    make-base-string: func [item [integer! string!]
    ][
        if integer? item
        [
            if item > length? default-digits
            [make error! join error-messages/1 length? default-digits] ;; base too large
            item: copy/part default-digits item
        ]
        if not case-sensitive [uppercase item]
        if 2 > length? item
           [make error! join error-messages/2 length? item]  ;; gotta be at least base-2
        if all [not case-sensitive (length? item) <> length? unique item] ;; duplicate digits
           [make error! join error-messages/3 item]
        if all [case-sensitive (length? item) <> length? unique/case item] ;; duplicate
           [make error! join error-messages/3 item]
        return item
    ] ;; func

;;  =======================================================
;;  function to test drive the conversions -- useful if you
;;  make changes and want to run some verification tests
;;  =======================================================
    test-drive: func [/local tests-count
                             base
                             number
    ][
        tests-count: 0
        forever
        [
            if 0 = (tests-count // 1000)
            [
                print [now/time " Tests completed: " tests-count]
            ]
            tests-count: tests-count + 1

        ;;  Test decimal --> base --> decimal
        ;;  ---------------------------------

            base: maximum 2 random/secure 36
            number: random/secure maximum-decimal
            if number <> result: from-base to-base number base base
            [
                print [tests-count "//1: Failure on base:" base " Number: " number " -- " result]
            ]

        ;;  Test base --> decimal --> base
        ;;  ------------------------------
            base: random/secure copy default-digits
            base: copy/part base maximum 2 random/secure length? base
            number: copy ""

            loop random/secure length? base [append number random/only base]

            loop -1 + length? number   ;; remove leading "zeroes" from number
                [either number/1 = base/1
                    [number: copy skip number 1]
                    [break]
                ]
            result: from-base number base
            if result < maximum-decimal   ;; can't convert back if too large
              [result: to-base result base
                if result <> number
                [
                    print [tests-count "//2: Failure on base:" base " Number: " number " -- " result]
                ]
              ]
        ] ;; forever
    ] ;; func
] ;; object







;; ========================
;; view-base-convert object
;; ========================

view-base-convert: make object!
[

  ;; Data variables for layout
  ;; -------------------------

  from-base:
    to-base:
     number:
     result: none

run: func [
  /local
][
 unview/all
 view/new xx: layout
  [
   across
   banner "Convert between bases"
   return
   from-base: rotary  "xx"
            [view-base-convert/convert]
   number: field 250 bold white font-color blue
            [view-base-convert/convert]
   return
   to-base: rotary    "xx"
            [view-base-convert/convert]

   result: info 250 bold blue font-color white
   return
   button "convert!" [view-base-convert/convert]
  ]

  ;; Set rotaries
  ;; ------------

  from-base/data: copy []
    to-base/data: copy []
  for nn 2 36 1
     [
      append from-base/data join "from " nn
      append   to-base/data join "to " nn
     ]
  from-base/data: skip from-base/data 8    ;; base 10
    to-base/data: skip to-base/data 14     ;; base 16
  show from-base
  show to-base


  ;; Fire it up
  ;; ----------

   do-events


   return true
]

;; =====================================================

convert: func [
  /local
   b-from
   b-to
   base10-value
   baseN-value
   oops
][

;; ---------------------------------------------
;; We could do this a bit faster by checking
;; if either of the bases is 10, but let's not!
;; ----------------------------------------------


error? oops: try
   [
    b-from: to-integer skip from-base/text 5
    b-to:   to-integer skip to-base/text 3

    base10-value: base-convert/from-base number/text b-from
    baseN-value: base-convert/to-base base10-value b-to
    result/text: baseN-value
    show result
    return true
   ]

;; Oops -- something has gone wrong
;; --------------------------------

oops: disarm oops
result/text:  oops/arg1
show result
return true

]


] ;; object


;; ===============================
;; Start the View/Plugin front end
;; ===============================

view-base-convert/run
