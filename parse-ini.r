REBOL [
    Title:  "Parse ini file"
    Date:   15-Apr-2009
    Author: "Sunanda"
    File:   %parse-ini.r
    Purpose: "Parses a Window's ini file. Also a function to find entries in a parsed ini file"
    library: [
        level: 'beginner
        platform: 'windows
        type: 'Tool
        domain: [file-handling parse win-api]
        tested-under: 'windows
        support: none
        license: 'bsd
        see-also: none
    ]
    Version: 1.0.2
    History: [
        [1.0.0  2-oct-2004 "First release"]
        [1.0.1  4-feb-2007 "Fix bug that drops the last section -- thanks, robiandi!"]
        [1.0.2 15-apr-2009 "Fix bug that failed to parse comments -- thanks, sqlab!"]
        ]
]

;; =====================
;; Comments on script:
;;         Altme: http://www.rebol.org/aga-display-posts.r?post=r3wp162x826
;; REBOL.org: http://www.rebol.org/discussion.r?script=parse-ini.r
;;


;;  ==============
;;  parse ini file
;;  ==============

parse-ini-file: func [
    file-name [file!]
   /local ini-block
    current-section
    parsed-line
    section-name
][
 ini-block: copy []
    current-section: copy []
    foreach ini-line read/lines file-name [
		if #";" <> first ini-line [ ; do not process comment lines
			section-name: ini-line
			error? try [section-name: first load/all ini-line]
			either any [
				error? try [block? section-name]
				not block? section-name
			][
				parsed-line: parse/all ini-line "="
				append last current-section parsed-line/1
				append last current-section parsed-line/2
			][
				append ini-block current-section
				current-section: copy []
				append current-section form section-name
				append/only current-section copy []
			] ;; either
		]
    ] ;; for
 append ini-block current-section
 return to-hash ini-block
 ]

;;  ===========
;;  Find in ini
;;  ===========

Find-in-ini: func [
        ini   [hash!]
    section [string!]
       item [string!]
][
    error? try [return select/skip select ini section item 2]
    return false
]


;;  =========
;;  test data
;;  =========
ini: parse-ini-file %/c/windows/win.ini

 print find-in-ini ini "ports" "com1:"
 print find-in-ini ini "intl" "iCountry"
 print find-in-ini ini "truetype" "FontSmoothing"
 print find-in-ini ini "xxx" "xxxx"