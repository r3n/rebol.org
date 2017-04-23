REBOL [
       Title: "Safe CGI data retriever"
       Date: 21-may-2006
       File: %safe-cgi-data-read.r
     Author: "Sunanda"
    Purpose: {
        Safely retrieves CGI GET or POST data
        into a REBOL object.
   }

    library: [
      level: 'intermediate
      platform: 'all
      type: [function how-to tool]
      domain: [cgi other-net]
      tested-under: [Windows UNIX]
      support: none
      license: 'mit
      see-also: none
    ]
]

safe-cgi-data-read: func [ "Safe way to read CGI parameter data"
  /template template-obj [object!] "Default values"
  /keep-blocks "Do not collapse blocks to strings"
  /no-trim   "Do not trim whitespace"
  /refresh  "Do not use cached data"
  /local
   cgi-string
   cgi-block
   cgi-object
   read-cgi
   temp
][

;; -----------------------------
;; Inner function -- copied from
;; http://www.rebol.com/docs/words/wread-io.html
;; ---------------------------------------------

read-cgi: func [
	;Read CGI data. Return data as string or NONE.
	/local data buffer
][
	switch system/options/cgi/request-method [
		"POST" [
			data: make string! 1020
			buffer: make string! 16380
			while [positive? read-io system/ports/input buffer 16380][
				append data buffer
				clear buffer
			]
		]
		"GET" [data: system/options/cgi/query-string]
	]
	data
]


;; -------------------------
;; mainline code starts here
;; -------------------------
     ;; -----------------------------------
     ;; Read CGI -- unless we had it cached
     ;; already from a previous invocation
     ;; -----------------------------------

 cgi-string: ""
 if refresh [clear cgi-string]
 if cgi-string = "" [temp: read-cgi if string? temp [append cgi-string temp]]

    ;; ------------------------------------------
    ;; preprocess to fix bad ampersands and SELF=
    ;; ------------------------------------------

 insert cgi-string "&"            ;; insert to make life easier
 while [find cgi-string "&&"] [replace/all cgi-string "&&" "&"]
 replace cgi-string "&self=" "&__self="
 cgi-string: copy next cgi-string ;; drop the inserted ampersand

    ;; ------------------------------
    ;; create a block with decode-cgi
    ;; ------------------------------
    ;; This may fail if the parameters
    ;; are badly formed -- like
    ;; "&=1"
    ;; decode-cgi may also return NONE
    ;; or a zero-length string if is no
    ;; cgi data to read

 cgi-block: copy []
 attempt [cgi-block: decode-cgi cgi-string]
 if not block? cgi-block [cgi-block: copy []]

   ;; ---------------------------------------
   ;; Post-process the resulting data fields:
   ;; ---------------------------------------
   ;; -- changing blocks to strings, if requested
   ;; -- trimming whitespace, if requested

 for n 2 length? cgi-block 2 [
    temp: cgi-block/:n
    if all [not keep-blocks
            block? temp][
         temp: form temp
        ]
    if all [string? temp not no-trim] [trim/lines temp]
    poke cgi-block n temp
    ]


   ;; ----------------------------
   ;; Heft into object, and return
   ;; ----------------------------

 if not template [return make object! cgi-block]
 return construct/with cgi-block template-obj
]










