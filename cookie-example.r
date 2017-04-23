#!c:\rebol\lib-core\rebol.exe -cs

;; you will need your own shebang on the line above

REBOL [
    Title: "cookie-example.r"
    Date: 6-october-2003
    Version: 1.0.1
    File: %cookie-example.r
    Author: "Sunanda"
    Purpose: {Demonstrates how to set session cookies and use them to retrieve
            session variables. Much of the code has been cobbled together from
            much more structured (ie not all in one module) code used by
            rebol.org itself}
    library: [
        level: 'intermediate
        platform: 'all
        type: 'demo
        domain: [cgi web]
        tested-under: none
        support: none
        license: bsd
        see-also: none
    ]
]

;; function to send page
;; ----------------------
send-output: func [html [string!]]
[

    print "Content-type: text/html^/"
    print html
    quit
]


; =======================================
clear-place-holders: func [str [string!]
                    /local out-str ph
                    len old-len
                    ]
;; ---------------------------------------
;; In some pages we'll have some place-holders
;; left over when we've finished replacing the
;; ones in use. This function removes the
;; remaining ones.
;; A place-holder is identified as starting
;; and ending with "!!".
;; -------------------------------------------

[
out-str: copy str

 forever [
    ph: none
    parse/all out-str [thru "!!"  copy ph to "!!"]
    if none? ph [break]
    replace/all out-str join "!!" [ph "!!"] ""
    ]

return trim/lines out-str   ;; no one needs spaces in a web-page
                            ;; unless you have <pre>
]


;;  ====================================
defuse-cgi-field: func [field [string!]]

;;  Input CGI fields that contain <, > or & are
;;  bad for security if we just slip-stream them into
;;  the output. The could contain "active" elements
;;  like HTML formatting or Javascript code
;;  We defuse them by converting harmful characters to
;;  their equivalent entities
[

 replace/all field "&" "&amp;"
 replace/all field "<" "&lt;"
 replace/all field ">" "&gt;"
 return field

]


read-cgi: func [
;; --------------------------------------------
;; Read CGI data. Return data as string or NONE.
;; Lifted from Carl's viewback.cgi.
;; --------------------------------------------
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



;;  =======================
;;  gets or sets the cookie
;;  Assumed to be in the format
;;  keyword=xxxxxxxxxxxx
;;  =======================
    cookie: func    [/get
                     /set cookie-data [string!]
                     /local pointer
                     				cookie-value
                     ]
[


 if get [
 		 	  cookie-value: select system/options/cgi/other-headers "HTTP_COOKIE"
 		 	  if none? cookie-value [return none]
 		 	  return first parse cookie-value "="
      ]

 if set
    [

     pointer: find  system/options/cgi/other-headers "HTTP_COOKIE"
     either none? pointer
            [
             append system/options/cgi/other-headers "HTTP_COOKIE"
             append system/options/cgi/other-headers cookie-data

            ]
            [
             poke system/options/cgi/other-headers (1 + index? pointer) cookie-data
             ]
     print join "set-cookie: " form cookie-data      ;; sends cookie to browser

     return true
    ]
]


;; ================================
;;  Read user data from the cookie.
;;
;;  Returns:
;;  -- an object if cookie points to a user data record
;;  -- false if it doesn't
;;  ================================
read-user-record-from-cookie: func [
                    /local cookie-value
                        cookie-split
                        user-data
                        error-code
                    ]

[   cookie-value: cookie/get
    if none? cookie-value [return "no cookie"]
    if error? error-code: try [user-data: do read to-file form cookie-value]
            [return join "bad read" mold disarm error-code]

    return user-data
]


;; ========================================
write-user-record: func [user-data [object!]
                    /local
                    ]

[

 user-data/last-active-date: now/precise


 write  to-file  form cookie/get
            mold user-data
 return true


]


Web-page: {
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"
    "http://www.w3.org/TR/REC-html40/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html;CHARSET=iso-8859-1">
<meta name="Author" content="Sunanda">
<title>Cookie-example.r from the REBOL.org Script Library
</title>
</head>

<body>
<div class="header">
<form class="header" action="cookie-example.r" method="GET">
<h1>Cookie-example.r</h1>
<p>Type stuff into the text field below. It will be reflected
into the next paragraph. Because we store a cookie in your
browser and an object on the web-server, we can rembemer what you
typed and we will reflect all previous strings typed until you
exit the browser.
</p>
<h2>Input text</h2>
<input type="text" alt="input-text" name="input-text" value="!!input-text!!" size="100">

<input type="submit" alt="send button" name="send-button" value="send">

<h2>Cumulative text from previous sends</h2>
<p style="color: blue">!!cumulative-text!!</p>

<h2>You last pressed enter on !!last-active!!</h2>

<h2>Your cookie is</h2>
<p style="color: Red">!!cookie!!</p>



</form>
</body>
</html>

}




;;  Main processing starts here
;;  ===========================

if error? cgi-error: try [

cgi-input: read-cgi


;;  No cgi? Give them a page with all fields empty and retire
;; -----------------------------------------------------------

if any [none? cgi-input
        "" = cgi-input
        ]
        [send-output clear-place-holders web-page]


;; we got data
;; ------------

;;  create object with all fields
;;  ----------------------------
cgi-object: make object! []
cgi-object: construct/with decode-cgi cgi-input cgi-object


;;  check if required fields are present
;;  -------------------------------------

if error? try [cgi-object/input-text]
    [
     send-output clear-place-holders web-page
    ]


;;  get or set the cookie
;;  =====================

user-data-object: read-user-record-from-cookie
user-data-was: mold user-data-object


if not object? user-data-object
    [
     cookie/set: form checksum/secure form now/precise

     user-data-object: make object!
        [last-active-date: none
         user-data: copy []
        ]

    ]

;;  We now have a new user-data object,
;;  or the one from the last time.
;;  Now we add to the saved user data,
;;  and reflect back all the data

append user-data-object/user-data form cgi-object/input-text

foreach text user-data-object/user-data
    [
     replace web-page "!!cumulative-text!!"
        join defuse-cgi-field text [<br />"!!cumulative-text!!"]
    ]


;;  Reflect the input fields to the output page
;;  ------------------------------------------

replace web-page "!!input-text!!" defuse-cgi-field cgi-object/input-text
replace web-page "!!cookie!!"  cookie/get

replace web-page "!!last-active!!" user-data-object/last-active-date

;;  Save the user record
;;  --------------------


write-user-record user-data-object

send-output clear-place-holders web-page

]

;;  cgi error code
;;  --------------
[
    print "Content-type: text/html^/"
    print "<h1>Oops we had an error</h1>"
    print mold disarm cgi-error
    quit
    ]