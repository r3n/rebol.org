REBOL [
	Title:	"rank-utils.r"
	Date:	20-Jul-2005
	File:	%rank-utils.r
	Author:	"Sunanda"
	Version: 0.0.0
	Purpose: "Rank scripts found by search"
	History: [0.0.0	20-Jul-2005 {started. Sunanda}
		]
]


rank-utils: make object! [

 indexes-to-use: [
        "old"                       ;; pre skimp indexes
        "body" "header" "comments"  ;; skimp indexes
        "strings" "documenation"
        ]

 error? try [indexes-to-use: copy library-globals/indexes-to-use]




;; =========================================
;; Sort results by likely relevance criteria
;; =========================================
rank-by-relevance: func [
  items [block!]
  target [string!]
  /local
   weights-table
   target-words
   summed-weight
   results
][

;; ------------------------------------------
;; (this needs some refactoring elsewhere)
;; Remove results if we are not searching that
;; index
;; -------------------------------------------

 if find target "[b]" [
    indexes-to-use: ["body"]
    items: copy []     ;; remove all search results,
                       ;; so we rely purely on skimp
    ]


;; ------------------------------------------
;; Stage 1: weight by header factors
;; -------------------------------------------

 weights-table: [
           'author  [100 30 15 30]    ;; exact match  + match + match in first half + any match
           'title   [40 20 30 5]
           'purpose [20 15 10 10]
           'file    [100 50 50 25]
          ]

 target-words: shred-target target


     ;; remove noise words -- they add nothing to the search accuracy
 foreach noise-word ["in" "the" "a" "title" "purpose" "author" "contains" "is"]
     [
      if find target-words noise-word [alter target-words noise-word]
     ]


 for nn 1 length? items 1
     [
       summed-weight: 0
       foreach tw target-words
           [
            foreach [field weights] weights-table
               [
                summed-weight: summed-weight + calc-weight tw weights select items/:nn field
               ]

           ]
     insert items/:nn summed-weight
     insert items/:nn 'weight
     ]


;; Stage 2: Refine according to the skimp indexes
;; ----------------------------------------------

      ;; desktop version does not have skimp indexes,
      ;; so this will fail.....No matter: they get
      ;; a reasonable ranking, though not as good
      ;; as rebol.org because that has better and
      ;; fatter indexes.
error? try [items: add-skimp-results items target]


;; Stage 3: sort according to weightings
;; -------------------------------------

 items: sort-items items target

 return items
]




;; ======================================
calc-weight: func [target-word [string!] weights [block!] field
  /local
   sum
][


 if 1 = length? target-word [return 0]  ;; short words don't count
 if 2 = length? target-word [return 0]  ;; short words don't count

 if file? field [field: form field]

 if not string? field [return 0]        ;; ignore the nones

 if field = target-word [return weights/1]

 sum: 0

 if find parse field " " target-word [sum: sum + weights/2]  ;; matches a word
 if find copy/part field to-integer (0.5 * length? field) target-word
              [sum: sum + weights/3]
 if find field target-word [sum: sum + weights/4]


 return sum

]




;; ===========================================
add-skimp-results: func [
   items  [block!]
   target [string!]
  /local
   target-words
   skimp-matches
   new-finds
   script-name
   weight
   old-matches
   header-copy
   documentation-matches
   weights-table
][

 target-words: shred-target target

 if 0 = length? target-words
     [return items]         ;; no skimp-able words -- so can't help


 lib-utils/do-if 'skimp %skimp.r

 ;; Find matches according to Skimp
 ;; -------------------------------
 ;; This set of loops adds an entry
 ;; to skimp-matches if *all* words
 ;; in the target are in one or more
 ;; of the indexes.....So if we are
 ;; looking for "help system file"
 ;; and all three words are found
 ;; in the comments of a script,
 ;; then that is match.
 ;;
 ;; Note if "help system" is in the
 ;; comments and "file help" is in
 ;; the header, that is not a match...
 ;; we're dependent on librarian-lib
 ;; to have found all such matches.


 weights-table: copy []


 foreach [index weight] [
     "header"        50
     "comments"      20
     "strings"       25
     "body"          10
     "documentation" 35
    ][
    if find indexes-to-use index [
       append weights-table index
       append weights-table weight
       ]
    ]

 skimp-matches: copy []
 documentation-matches: copy []
 foreach [index weight] weights-table
    [
        foreach skimp-hit skimp/find-words
                      join idx-utils/script-index-dir [index "/" index]
                              target-words
             [
              add-to-skimp-matches skimp-matches skimp-hit weight
              if index = "documentation" [append documentation-matches skimp-hit]
             ]
    ]

documentation-matches: sort unique documentation-matches


;; Adjust the skimp weights
;; ------------------------
;; The above code made an entry
;; in skimp-matches for scripts
;; with all matching words. We're
;; now going to bump those matches
;; for *any* matching word.
;; So if we are looking for
;; "help system file" then "help"
;; in both comments and body will
;; increase the weighting a little.
;; But we do not create any new
;; matches

 weights-table: copy []


 foreach [index weight] [
     "header"        5
     "comments"      3
     "strings"       4
     "body"          6
     "documentation" 4
    ][
    if find indexes-to-use index [
       append weights-table index
       append weights-table weight
       ]
    ]


 foreach [index weight] weights-table
    [
     foreach word target-words
       [
         foreach skimp-hit skimp/find-word
                       join idx-utils/script-index-dir [index "/" index]
                               word
             [add-to-skimp-matches/only skimp-matches skimp-hit weight]
       ]
    ]






 ;; Adjust the weights of existing matches
 ;; ---------------------------------------


 old-matches: copy []
 for nn 1 length? items 1
    [
     script-name: form select items/:nn 'file

     if weight: select skimp-matches script-name
         [
          poke items/:nn 2 weight + items/:nn/2
          append old-matches script-name
          if find documentation-matches script-name
             [append items/:nn 'doc?  ;; add entry to say we found a match in the documentation
              append items/:nn "yes"
             ]
         ]
    ]


new-finds: copy []
foreach [script-name weight] skimp-matches
    [
     if not find old-matches script-name
            [append new-finds reduce [script-name weight]]
    ]


if 0 = length? new-finds [return items]

;; --------------------------------------------
;; We've found things that the non-skimp search
;; hasn't.  So we need to add them to the search
;; results
;; ----------------------------------------------
;; script-index is a global from librarian-lib.r



foreach header script-index
  [
   script-name: form select header 'file
   weight: select new-finds script-name
   if none <> weight
      [
       header-copy: copy/deep header
       insert header-copy weight
       insert header-copy 'weight
       if find documentation-matches script-name
             [append header-copy 'doc? ;; add entry to say we found a match in the documentation
              append header-copy "yes"
             ]

       append/only items header-copy
      ]
  ]

 return items
]

;; ========================================
add-to-skimp-matches: func [match-table [block!]
                            script-name [string!]
                            weight [integer!]
                           /only
    /local
     pointer
][
     either pointer: find match-table script-name
      [
       pointer: (index? pointer) + 1
       poke match-table pointer weight + pick match-table pointer
      ]
      [if not only
         [insert match-table weight
          insert match-table script-name
         ]
      ]

 return true
]


;; ================================================
sort-items: func [items [block!] target [string!]
  /local
  specialised-sort
][

 if find target "size"
    [
     specialised-sort: sort-by-size items target
     if block? specialised-sort [return specialised-sort]
    ]

 sort/compare items    ;; Can assume 'weight is 2nd entry
    func [a b /local a-file b-file
    ][
      if a/2 > b/2 [return -1]
      if a/2 < b/2 [return +1]

           ;; equal weight: sort by script name
      a-file: select a 'file
      b-file: select b 'file
      if a-file < b-file [return -1]
      if a-file > b-file [return +1]
      return 0
    ]

 return items
]


;; =======================================================
sort-by-size: func [items [block!] target [string!]
  /local
  target-words
  sort-return
][
;; ---------------------------------------
;; If the search appears to be
;;      "size < nnnn" or
;;      "size > nnn"
;; we'll sort that way

 target-words: parse target " "
 if any [3 <> length? target-words
         target-words/1 <> "size"
         not find ["<" ">" "<=" ">="] target-words/2
        ]
        [return none]         ;; not a size sort


 sort-return: [-1 +1]
 if find [">" ">="] target-words/2  [sort-return: head reverse sort-return]


 sort/compare items    ;; Can assume 'weight is 2nd entry
    func [a b /local a-size b-size
    ][
      a-size: select a 'size
      b-size: select b 'size
      if a-size < b-size [return sort-return/1]
      if a-size > b-size [return sort-return/2]
      return 0
    ]

return items

]

shred-target: func [target [string!]
			/local
			lines
			unquoted-text
			token
			word-list
			letters-rule
			word-rule
			block-rule
			winnowed-list
			]
[
 ;;	Returns a block with all the searchable words in the target
 ;;	----------------------------------------------------------

;;	Remove quoted lines
;;	-------------------
lines: parse target form newline
unquoted-text: copy " "
foreach line lines
	[append line " "
	 if all
	 			[0 <> length? line
	 			 0 <> length? trim/lines line
	 			 #">" <> line/1
	 			]

	 	[
	 	 append unquoted-text line
	 	 append unquoted-text " "
	 	]
	]

;;	Remove everything but a-z, 0-9, "-" and "/"
;;	-------------------------------------------

lowercase unquoted-text
token: copy ""
word-list:  copy []

letters-rule: charset [ #"a"  -  #"z"
                        #"0" - #"9"
                        #"/"
                        #"-"
                        ]


word-rule:    [some letters-rule]
block-rule:   [copy Token word-rule
                    (append word-list Token token: copy "")
                    | skip]

parse/all unquoted-text [some block-rule]

word-list: unique word-list



;;	Now dump any word that breaks the rules
;;	---------------------------------------
winnowed-list: copy []

foreach word word-list
	[
	 if all [20 > length? word		;; too long
	         1 < length? word			;; too short
	         #"a" <= word/1				;; doesn't start with two letters
	         #"z" >= word/1
	 			   #"a" <= word/2
	 			   #"z" >= word/2
	 			  ]
	 			  [append winnowed-list word]

	]

return winnowed-list

]



] ;; object
