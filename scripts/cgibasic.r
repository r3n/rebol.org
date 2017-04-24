REBOL [
    Title: "CGI common procedures"
    Author: "Steven White"
    File: %cgibasic.r
    Date: 10-Nov-2011
    Purpose: {This is a collection of functions that could be used in a
    CGI program.  There is nothing in this module that has not been done
    better by others, but the code is more heavily annotated for beginners.
    Separate documentation explains how to use the functions.  The comments
    should be helpful also.  None of this is my original creation. I just
    assembled and annotated, mainly so I could use it and understand it.}
    library: [
        level: 'beginner
        platform: 'all
        type: [tutorial tool]
        domain: [cgi]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This is a module of common procedures used in a CGI program.              ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This little procedure displays the header that is required                ]
;; [ when sending an html page back to the browser.                            ]
;; [ The procedure is separate because, while it must be done,                 ]
;; [ and it must be the first thing done, the caller might be                  ]
;; [ sending back a regular page, or a debugging page, or                      ]
;; [ who-knows-what, so we will let the caller do this when he                 ]
;; [ wants to.  But he must.                                                   ]
;; [---------------------------------------------------------------------------]

CGI-DISPLAY-HEADER: does [
    print "content-type: text/html"
    print ""
    print ""
]

;; [---------------------------------------------------------------------------]
;; [ This procedure is used to gradually build up a string of HTML             ]
;; [ to return to the browser.  When this module is first loaded,              ]
;; [ it makes a string to hold the HTML.  Then, is is called                   ]
;; [ repeatedly with a block of REBOL code and data as a parameter.            ]
;; [ The procedure evaluates any REBOL expressions ("reduces" them)            ]
;; [ and then appends the result to the end of the string we are               ]
;; [ building.  Finally, it puts a line-feed at the end so we don't            ]
;; [ create just one gigantic string as the final result.                      ]
;; [ (This will be appreciated by anyone who tries to view the                 ]
;; [ source of the resulting page with the browser.)                           ]
;; [---------------------------------------------------------------------------]

CGI-OUTPUT: make string! 5000
CGI-EMIT-HTML: func [CGI-OUT-LINE] [
    repend CGI-OUTPUT CGI-OUT-LINE
    append CGI-OUTPUT newline
]

;; [---------------------------------------------------------------------------]
;; [ This procedure uses the above procedure and is an alternate               ]
;; [ way to emit HTML.  This procedure accepts a file name as a                ]
;; [ parameter and reads that file into a string, and then calls               ]
;; [ the above procedure to add the file to the end of the HTML                ]
;; [ string that is being built up by the above procedure.                     ]
;; [ Before this procedure calls the above procedure, it runs the              ]
;; [ build-markup function on the file it read.  That function                 ]
;; [ locates special tags (<% and %>) and runs REBOL code inside               ]
;; [ those tags, similar to what PHP does.  Inside those tags                  ]
;; [ there can be REBOL words to be evaluated.  It is the job of               ]
;; [ the caller of this procedure to make sure that any words                  ]
;; [ used inside the build-markup tags are actually defined in                 ]
;; [ the calling program.                                                      ]
;; [---------------------------------------------------------------------------]

CGI-EMIT-FILE: func [
    CGI-FILE-TO-EMIT [file!]
] [
    CGI-EMIT-HTML build-markup read CGI-FILE-TO-EMIT
] 

;; [---------------------------------------------------------------------------]
;; [ This is a procedure that attempts to do as much as possible               ]
;; [ to help in the processing of CGI form data.                               ]
;; [ The procedure CGI-GET-INPUT reads the CGI data in whatever                ]
;; [ form it is presented                                                      ]
;; [ (POST or GET), and then puts the raw data into a string                   ]
;; [ called CGI-STRING.  Then it uses the decode-cgi command to                ]
;; [ break it apart into name/value pairs.                                     ]
;; [ It passes the name/value pairs to the construct function                  ]
;; [ which makes them into a context called CGI-INPUT.                         ]
;; [ As a context, the data can be referenced as                               ]
;; [ CGI-INPUT/data-name where data-name is a name specified in                ]
;; [ the "name" attribute in the HTML form.                                    ]
;; [---------------------------------------------------------------------------]

CGI-STRING: ""
CGI-GET-INPUT: does [
    CGI-STRING: CGI-READ
    CGI-INPUT: construct decode-cgi CGI-STRING
]
CGI-READ: func [
    "Read CGI data (GET or POST) and return as a string or NONE"
    /limit CGI-MAX-INPUT "Limit input to this number of bytes"
    /local CGI-DATA CGI-BUFFER
] [
    if none? limit [CGI-MAX-INPUT: 100000]
    switch system/options/cgi/request-method [
        "POST" [
            CGI-DATA: make string! 1020
            CGI-BUFFER: make string! 16380
            while [positive? read-io system/ports/input CGI-BUFFER 16380] [
                append CGI-DATA CGI-BUFFER
                clear CGI-BUFFER
                if (length? CGI-DATA) > CGI-MAX-INPUT [
                    print ["aborted - form input too large:"
                        length? CGI-DATA "; limit:" CGI-MAX-INPUT]
                    quit
                ]  
            ]
        ]
        "GET" [
            CGI-DATA: system/options/cgi/query-string
        ]
    ]
    CGI-DATA
]

;; [---------------------------------------------------------------------------]
;; [ This procedure exists for those cases where a CGI program                 ]
;; [ is going to display HTML code for the purpose of actually                 ]
;; [ displaying the code and not having that code rendered into                ]
;; [ an HTML display.  It accepts a string and replaces the                    ]
;; [ less-than and greater-than signs with the escape sequences                ]
;; [ that will cause a browser to display those signs instead of               ]
;; [ interpreting them.  This technique was harvested from the internet        ]
;; [ and is not my original creation.                                          ]
;; [---------------------------------------------------------------------------]

CGI-ENCODE-HTML: func [
    "Make HTML tags into HTML viewable escapes (for posting code)"
    CGI-TEXT-TO-ENCODE
] [
    foreach [CGI-TAG-CHAR CGI-ESC-SEQ] ["&" "&amp;" "<" "&lt;" ">" "&gt;" ] [
        replace/all CGI-TEXT-TO-ENCODE CGI-TAG-CHAR CGI-ESC-SEQ
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Here is/are some debugging procedure(s) we can use to find                ]
;; [ out where things might be going wrong.  When a CGI program                ]
;; [ doesn't work, many times it doesn't produce any output at                 ]
;; [ all.                                                                      ]
;; [---------------------------------------------------------------------------]

CGI-DEBUG-MESSAGE: ""
CGI-DEBUG-PAGE: {
<HTML>
<HEAD>
<TITLE>CGI debugging page</TITLE>
</HEAD>
<BODY>
<% CGI-DEBUG-MESSAGE %>
</BODY>
</HTML>
}
CGI-DEBUG-DISPLAY: func [
    CGI-DEBUG-BLOCK [block!]
] [
    CGI-DEBUG-MESSAGE: reform CGI-DEBUG-BLOCK
    CGI-EMIT-HTML build-markup CGI-DEBUG-PAGE
    print CGI-OUTPUT
]

    
