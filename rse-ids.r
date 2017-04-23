rebol [
    Library: [
           level: 'intermediate
        platform: 'all
            type: [function tool package]
          domain: [database compression]
    tested-under: [windows bsd linux]
         support: none
         license: [mit]
        see-also: %skimp.r
        ]

       file: %rse-ids.r
       date: 20-feb-2007
     author:  ["Christian" "Romano" "Sunanda"]
    version: 0.0.1
      title: "Run sequence encoded integer data sets"
    purpose: "Provide an API for compacting/compressing sets of integers"
    ]

;; ================================================
;; Package information
;; ===================
;; This script is a package (ie a multi-file script)
;; on REBOL.org. But you do not need the downloadable
;; package files to install or run the script; this file
;; alone is necessary for that.
;; The other package files are test data suites. You could
;; use them to test any improvements you make to
;; this code.
;; To download the package components:
;;
;;     do http://www.rebol.org/library/public/repack.r
;;

;; ================================================
;; Documentation
;; =============
;; See http://www.rebol.org/cgi-bin/cgiwrap/rebol/documentation.r?script=rse-ids.r



;; ================================================
;; rse-ids.r
;; =========
;;
;; Run-sequence encoded integer dataset manager
;; --------------------------------------------
;;
;; 60 second summary:
;; ------------------
;; If you need a compact format for integer sequences,
;; then rse-ids.r may be for you.
;; For example, indexes (etc) may look something like this:
;;   "keyword" [2 4 5 6 7 8 9 10 12 13 14]
;; where:
;;   "keyword" is an identifier
;;   [...] is a block of integers that act as
;;         identifiers for some sort of resource.
;; as an rse-ids data structure, that would be compacted to:
;;   "keyword" [2 4x7 12x3]
;;
;; where:
;;     2   -- is an integer
;;     4x7 -- is a REBOL pair encoding 4,5,6,7,8,9,10, ie
;;            [start integer]x[sequence length]
;;            for sequences of 2 or more.



;; ================================================
;; Usage example:
;; ==============
;;
;; do %rse-ids.r
;;
;; dataset: copy [1 2 3 40 42 43 44]   ;; unique integers in ascending sequence
;; == [1 2 3 40 42 43 44]
;;
;; rse-dataset: rse-ids/compact dataset
;; probe rse-dataset
;; == [1x3 40 42x3]
;; rse-ids/find-compact rse-dataset 100
;; == false    ;; 100 not in data set
;; rse-ids/find-compact rse-data set 44
;; == true     ;; 44 is in data set
;; rse-ids/insert-compact rse-dataset 4
;; rse-ids/insert-compact rse-dataset 41
;; rse-ids/remove-compact rse-dataset 42
;; probe rse-dataset
;; == [1x4 40x2 43x2]
;; probe rse-ids/decompact rse-dataset
;; == [1 2 3 4 40 41 43 44]




;; ================================================
;; Provide backward-compatible
;; support for 'unless function
;; =============================

if not value? 'unless [
    unless: func [
        "Evaluates the block if condition is not TRUE."
        condition
        block [block!]
][
    if not condition [do block]]
]



;; ================================================
;; rse-ids object:
;; ===============

rse-ids: make object! [


;; Credits
;; =======
;;
;; compact          Romano
;; decompact        Romano
;; find-compact     Christian
;; insert-compact   Christian
;; remove-compact   Christian
;; sort-compact     Sunanda
;; _locate-compact  Christian
;; ***
;; Testing          Peter
;; ===========================


;; ======================= compact

compact: func [
    blk [block!]
    /unsorted
    /local
     out x n
][

if unsorted [sort-compact blk]

out: make block! (length? blk) / 2
parse blk [
    any [
        set x skip (n: x + 1) [
            some [1 1 n (n: n + 1)] (
                insert tail out add 1x0 * x n - x * 0x1
            )
            | (insert tail out x)
        ]
    ]
]
out
]




;; ======================= decompact

decompact: func [
    blk [block!]
   /unsorted
   /local
    out x n
][

if unsorted [sort-compact blk]

out: make block! 2 * length? blk
parse blk [
    any [
        set x integer! (insert tail out x)
        |
        set x pair! (n: x/2 - 1 x: x/1 insert tail out x)
        n (insert tail out x: x + 1)
    ]
]
out
]



;; ======================= find-compact

find-compact: func [
        blk   [block!]
    integer [integer!]
    /unsorted
][

if unsorted [sort-compact blk]

block? _locate-compact blk integer
]



;; ======================= remove-compact

remove-compact: func [
        blk   [block!]
    integer [integer!]
    /unsorted
    /local
     here value prev next
][

if unsorted [sort-compact blk]

if block? here: _locate-compact blk integer [
    either pair? value: first here [
        change/part here compose [(
                prev: (value/x * 1x0) + (integer - value/x * 0x1)
                prev: any [all [0 = prev/y []] all [1 = prev/y prev/x] prev]
            ) (
                next: (integer + 1 * 1x0) + (value/x + value/y - integer - 1 * 0x1)
                next: any [all [0 = next/y []] all [1 = next/y next/x] next]
            )] 1
    ][
        remove here
    ]
]
blk
]



;; ======================= insert-compact

insert-compact: func [
        blk   [block!]
    integer [integer!]
    /unsorted
    /local
     here prev next
][

if unsorted [sort-compact blk]

unless block? here: _locate-compact blk integer [
    here: at blk here
    next: all [
    next: pick here 1
    all pick [
           [integer + 1 = next  here: remove here next: 1x0 * integer +  0x2]
           [integer + 1 = next/x here: remove here next: next + -1x1]
        ] integer? next
    ]
   prev: all [
       prev: pick here -1
       all pick [
           [prev + 1 = integer here: remove back here prev: 1x0 * prev + 0x2]
           [prev/x + prev/y = integer here: remove back here prev:  prev + 0x1]
       ] integer? prev
    ]
   insert here any [
       all [none? next none? prev integer]
       all [prev next prev/x + prev/y - 1 = next/x 0x1 * next + prev - 0x1]
       any [prev next]
   ]
]
blk
]



;; ======================= sort-compact

sort-compact: func [
    blk [block!]
][
if 2 > length? blk [return blk]
for n 1 (length? blk) - 1 1 [
    if (first to-pair blk/:n) > (first to-pair pick blk n + 1) [
        sort/compare blk func [a b] [
            return (first to-pair a) < (first to-pair b)
        ] ;; sort
        return blk
    ] ;; if
] ;; for
return blk
]





;; Internal functions
;; ==================
;; Not intended for callers to use directly



;; ======================= _locate-compact

_locate-compact: func [
        blk   [block!]
    integer [integer!]
    /local
     left center right here value
][
left: 1 right: length? blk
while [all [left <= right not here]] [
    center: to integer! right - left / 2 + left
    unless any pick [[
            if integer < first value [right: center - 1]
            if (-1 + add first value second value) < integer [left: center + 1]
        ][
            if integer < value [right: center - 1]
            if value < integer [left: center + 1]
        ]] pair? value: pick blk center [here: center]
]
either here [at blk here] [right + 1]
]



] ;; rse-ids object