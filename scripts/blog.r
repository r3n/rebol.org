REBOL  [
    Title: "REBOL Blogger"
    Author: "Carl Sassenrath"
    Version: 1.3.2
    File: %blog.r
    Date: 10-Jan-2005
    Orig: 6-Jan-2005
    Purpose: {
        The blog system written and used by Carl Sassenrath,
        REBOL's creator. This script will let you post and
        update blogs on your website using just a web browser.
        Generates summary and index pages, blog searches, etc.
        Extensible with Makedoc2 for more formatting options.
    }
    Library: [
        level: 'intermediate
        platform: 'all
        type: [tool]
        domain: [cgi html http]
        tested-under: [core 2.5.6 on "Linux x86"]
        support: none
        license: 'BSD
        see-also: none
    ]
]

; Licensed under new BSD License. To summarize it:
; NO WARRANTY OF ANY KIND. USE ENTIRELY AT YOUR OWN RISK.
; Keep all the above information intact.

; Blog.r Feature Summary:
;  1. Allows remote blogging via html forms.
;  2. Automatically builds main blog page.
;  3. Creates a dated index to all blogs.
;  4. Creates links to and between blogs.
;  5. Use your website's standard page template.
;  6. Supports ranked seaches on blogs.
;  7. Provides a handy blog-content backup method.
;  8. Provides a form for feedback (but feedback system
;     is not a standard part of this blog.r script).
;  9. No database engine is needed.
; 10. Optionally generates static blog pages. [V1.3.0]
; 11. Supports multiple blogs on same site. [V1.3.0]

; Installation:
;  1. Upload this script to your CGI script directory.
;  2. Verify that you have a copy of REBOL/Core on your server.
;  3. Add a top line to point to REBOL/Core. Something like:
;     #!/usr/bin/rebol -cs
;  4. Change permissions (chmod 755) for blog.r to let it run.
;  5. Test it from a browser. If it has errors, you may need to
;     create the blog-dir dir and blog-reads file manually then
;     give them proper permissions (chmod 777 or 666). Be careful.
;  Read http://www.rebol.com/docs/cgi2.html for details.

print "content-type: text/html^/" ; activate web server content output

;-- Configuration ------------------------------------------------------------

; Automatically detect when running on client in test mode.
; (Causes the tested page to be displayed in the browser.)
test-mode: not system/options/cgi/request-method

; The website URL where your blog is located:
; Example: blog-site: http://www.example.com
blog-site: http://www.example.com

; Absolute path to the blog CGI script on your server. You can change this
; if you want more than one REBOL blog on your web site.
; Example: blog-cgi: %/cgi-bin/blog.r
blog-cgi: %/cgi-bin/blog.r

; Full blog URL (you don't normally need to change this):
blog-url: blog-site/:blog-cgi

; Where raw blog text files are stored relative to this script:
; Example: blog-dir: %blogs/
blog-dir: %blogs/

; Where blog HTML pages are cached after they are generated.
; This should be under the root directory of your website.
; Make sure it has permissions to allow CGI file writing.
; Set this to NONE if you always want dynamic (CGI) pages.
; Example: blog-root: %../html/blogs/
blog-root: %../html/blogs/

; The URL path to the above directory:
blog-path: %/blogs/

; How many blogs are printed on the main page:
max-blogs: 5

; How many blogs are indexed at the bottom of the main page:
max-links: 10

; The blog author/admin IP address. Only this address gets to post.
; If your client uses dynamic IP, then this will not work and you
; will need to use a username/pass with cookies to protect your blog.
; (That might be added to the next version of this blog script.)
admin-ip: "100.100.100.100"

; The name of the blogger:
author: "Your Name Here"

; IMG source link to author's photo location:
author-photo: %/photos/you.jpg

; The name of the organization:
organization: "Your Company Here"

; The titles of generated pages:
title: context [
    main-page:   "Your Name's Blog"
    index-page:  "Complete Index of Your Name Blogs:"
    search-page: "Results of Searching Blog:"
    feedback-page: "Send Feedback to Your Name"
]

; The meta decscription needed for search engines:
meta-description: trim/lines {
    Comments and ideas provided by Your Name via the
    REBOL Blogger.
}

; Blog page contents can be formatted with makedoc2 allowing nicer
; formatting of examples, etc. If the file below is not found, the
; default formatter will be used (just paragraph separation).
makedoc-script: %makedoc2.r

; Automatically detect when running on client in test mode.
; (Causes the tested page to be displayed in the browser.)
test-mode: not system/options/cgi/request-method

;-- HTML Templates -----------------------------------------------------------
;
; If you want to, you can cut and paste these into most HTML page editors to
; help revise them to get what you want. Just be sure to keep the {} braces.

; The name of the HTML template used for the look & feel. Fields within this
; template use the standard $variable format. See show-page function below.
template-file: %blog-template.html

; The default HTML template if the above file cannot be found. This also shows
; the variable format needed to create your own blog-template.html file:
html-template: {
    <html>
    <!--page generated by rebol-->
    <head><title>$title</title><style>
    body, p, td {font-family: arial, sans-serif, helvetica; font-size: 10pt;}
    h1 {font-size: 14pt;}
    h2 {font-size: 12pt; color: #2030a0; width: 100%; border-bottom: 1px solid #c09060;}
    h3 {font-size: 10pt; color: #2030a0;}
	tt {font-family: "courier new", monospace, courier; font-size: 9pt;}
	pre {font: bold 10pt "courier new", monospace, console;
		background-color: #f0f0f0; padding: 16px; border: solid #a0a0a0 1px;}
	.output {color: #803020}
	.note {background-color: #f0f0a0; width: 100%; padding: 16px; border: solid #a0a0a0 1px;}
    .title {font-size: 16 pt; font-weight: bold;}
    .label {margin-top: 3px; margin-bottom: 10px; width: 65px; text-align: right;
    font-weight: bold; vertical-align: top}
    </style></head>
    <body bgcolor="white">
    <center>
    <table width="660" cellpadding="4" cellspacing="0" border="0">
    <tr><td>
    <hr>
    <h1>$title</h1>
    <p>$content</p>
    <hr>
    </td></tr>
    <tr><td align=center>$date - $edit - 
    <a href=http://www.rebol.com>Blogger by REBOL</a></td></tr>
    </table></center></body></html>
}

; The HTML boilerplate used at the top of the first page:
html-main-boiler: [{
    <form action="} blog-cgi {" method="get">
    <table border=0 cellspacing=1 cellpadding=3>
    <tr><td width=32></td>
    <td width=119><img src="} author-photo {"></td><td>
    <b>} author {
    <br>} organization {
    <br>} date/date " " to-GMT date {</b>
    <br>} blog-count { readers since 4-Jan-2005</b>
    <br>[<a href="} blog-url {?index=0">Index of Prior Blogs</a>]
    <p>Search blogs: <input type=text size=25 name=find>
    </td></tr></table></form><p>
}]

; The HTML boilerplate used at the top of each separate blog page:
html-blog-boiler: [{
    <form action="} blog-cgi {" method="get">
    <table border=0 cellspacing=1 cellpadding=3>
    <tr><td width=32></td><td>
    <b>} author {
    <br>} organization {
    <br>} date/date " " to-GMT date {</b>
    <br>Blog #} file {</b>
    <br><span style="color: #808080">
    <a href="} blog-url {"><b>Main page</b></a>
    || <a href="} blog-url {?index=0">Blog index</a>} make-blog-links file
    { || <a href="} blog-url {?reply=} file {">Send feedback</a>
    </span>
    </td>
    </tr></table></form><p>
}]

; The HTML form used for inputing new blogs:
html-edit-form: [{
    <form action="} blog-cgi {" method="post">
    <span class=label>Date:</span>
    <input type=text size=40 name=date value="} date {">
    <br><span class=label>Title:</span>
    <input type=text size=72 name=title value="} title {">
    <br><span class=label>Text:</span>
    <textarea name=text rows=25 cols=72>} text {</textarea>
    <br><input type=hidden name=save value=} file {>
    <br><span class=label>&nbsp;</span>
    <input type=submit name=submit value=submit>
    </form>
}]

; The HTML form used for feedback replies:
html-reply-form: [{
    <form action="http://www.example.com/cgi-bin/feedback/post.r" method="post">
    <input type="hidden" name="type" size="-1" value="Blog">
    <br><span class=label>Subject:</span>
    <input type=text size=50 name=summary value="} subject {">
    <br><span class=label>Message:</span>
    <textarea name=textarea rows=10 cols=50></textarea>
    <br><span class=label>Email:</span>
    <input type=text size=40 name=email value=""> (Optional &amp; Private)
    <br><span class=label>&nbsp;</span>
    <input type=submit name=submit value=submit>
    </form>
}]

;-- Utility Functions --------------------------------------------------------

html: ""
emit: func [data] [repend html data]

safe-html: func [text] [
    ; Generate a "safe" html page:
    foreach [str code] [
        "&" "&amp;"
        "<" "&lt;"
        ">" "&gt;"
    ][replace/all text str code]
    text
]

to-GMT: func [date] [
    ; Extract a GMT time from DATE
    either date/time [
        date: fourth date - date/zone
        date/3: 0 ; remove seconds
        reform [date "GMT"]
    ][""]
]

file-num: func [n] [
    ; Output 000n file name format:
    n: form n
    insert/dup n "0" 4 - length? n
    to-file n
]

validate-user: does [
    ; Validate user has permission to post:
    if test-mode [return true]
    if system/options/cgi/remote-addr <> admin-ip [
        show-error "Permission denied."
    ]
]

;-- HTML Page Output ---------------------------------------------------------

show-page: func [title /edit link /main /build file /local template tag] [
    ; Show page thru CGI or locally in browser (for testing)
    template: attempt [read template-file]
    if not template [template: trim/auto html-template] ; use default
    if main [
        tag: build-tag [meta name "description" content (meta-description)]
        attempt [insert insert find/tail template <head> newline tag]
    ]
    title: to-string reduce title
    replace/all template "$title" title
    if build [edit: true link: file]
    if not link [link: 'new]
    tag: rejoin [{<a href="} blog-url {?edit=} link {">Edit</a>}]
    replace template "$edit" tag
    replace template "$date" now/date
    replace template "$content" html
    if edit [write join blog-root/:link ".html" template]
    if build [exit] ; just an update
    either not test-mode [
        print template
    ][
        write %temp-page.html template
        browse %temp-page.html
    ]
    quit
]

show-error: func [msg] [
    ; Output an error page:
    emit <b>
    emit msg ; (do not combine)
    emit </b>
    show-page "Blogger Error:"
]

;-- Blog File Handling -------------------------------------------------------

blog-obj: context [file: date: title: text: none]

load-blog: func [file /local blog] [
    attempt [
        blog: load/all join blog-dir file
        blog: construct/with blog blog-obj
        blog/file: file
        blog
    ]
]

save-blog: func [file date title text /local blog files] [
    validate-user
    date: to-date date
    blog: load-blog file
    if not blog [
        files: sort/reverse load blog-dir
        file: files/1
        file: either file [1 + to-integer file] [1]
        file: file-num file
    ]
    save join blog-dir file compose [
        date: (date)
        title: (title)
        text: (text)
    ]
    file
]

find-blog: func [blog strs /local rank text][
    ; Ranks blog contents during a search:
    rank: 0
    foreach str strs [
        if find/any blog/title str [rank: rank + 4]
        text: blog/text
        while [text: find/any/tail text str] [rank: rank + 1]
    ]
    rank
]

backup-blogs: func [start /local files] [
    ; This backs up the blog on a remote site so you don't lose them.
    ; The remote site should CGI with blog.r?back=n where n the start.
    ; This can easily be done with a few lines of REBOL for backup.
    validate-user
    system/options/binary-base: 64
    start: to-integer start
    out: copy []
    foreach file load blog-dir [
        if (to-integer file) >= start [
            repend out [mold file compress read join blog-dir file]
        ]
    ]
    print out
    quit
]

rebuild-blogs: does [
    ; Rebuild all cached HTML blog pages. To run this, browse
    ; with a URL like: http://.../cgi-bin/blog.r?rebuild=0
    validate-user
    if blog-root [
        foreach file load blog-dir [
            clear html
            print ["Building:" file <br>]
            show-blog/build file
        ]
        print "Done"
        quit
    ]
]

;-- Blog Page Formatters -----------------------------------------------------

title-blog: func [blog] [
    ; Generates a blog title line:
    reform [blog/date/date "-" blog/title]
]

link-blog: func [value text] [
    ; Generates an HTML hyper link:
    rejoin [
        {<a href="}
        either blog-path [
            join blog-path/:value ".html"
        ][
            join blog-url ["?view=" value]
        ]
        {">} to-string reduce text </a>
    ]
]

blog-line: func [blog] [
    ; Generates a full blog summary line:
    rejoin [
        "" <span style="text-align: right; width: 1in"> blog/date/date </span>
        " - " <b> link-blog blog/file blog/title </b> " [" blog/file "]" newline
    ]
]

format-text: func [text] [
    ; Formats text for output:
    either exists? makedoc-script [
        ; Use the Makedoc2 text-to-html formatter:
        if not find text "^/^/###" [append text "^/^/###"]
		do/args makedoc-script 'load-only
		text: scan-doc/options text [no-title]
		second gen-html/options text [no-title no-toc no-nums no-indent no-template]
    ][
        replace/all text "^/^/" "^/<p>"
    ]
]

show-blog: func [file /build /local blog date] [
    ; Show a single blog page:
    blog: load-blog file
    if not blog [show-error ["Blog " file " was not found"]]
    date: blog/date
    emit bind html-blog-boiler 'blog
    emit format-text blog/text
    either build [
        show-page/build blog/title file
    ][
    show-page/edit blog/title file
]
]

show-main: has [n blog date] [
    ; Show the main blog page:
    date: now
    emit bind html-main-boiler 'date
    n: 1
    foreach file sort/reverse load blog-dir [
        if blog: load-blog file [
            either n > max-blogs [
                emit [blog-line blog <br>]
            ][
                emit [<h2> title-blog blog " [" link-blog file file "]" </h2>]
                emit format-text blog/text
            ]
            if n = max-blogs [emit [<h2> "Other Recent Blogs:" </h2><blockquote>]]
            n: n + 1
            if (n - max-blogs) > max-links [break]
        ]
    ]
    emit </blockquote>
    emit [{<b><a href="} blog-cgi {?index=0">Click here for list of all prior blogs.</a></b><p>}]
    show-page/main title/main-page
]

show-index: has [blog] [
    ; Show the blog index page:
    emit <blockquote>
    foreach file sort/reverse load blog-dir [
        if blog: load-blog file [emit [blog-line blog <br>]]
    ]
    emit </blockquote>
    show-page title/index-page
]

show-search: func [text /local rank list blog] [
    ; Show the results of a blog search, listed by search-hit rank:
    text: parse text none
    list: copy []
    foreach file load blog-dir [
        if blog: load-blog file [
            rank: find-blog blog text
            if rank > 0 [repend list [rank blog]]
        ]
    ]
    sort/reverse/skip list 2
    emit ["The search found " (length? list) / 2 " blogs:<p><blockquote>"]
    foreach [rank blog] list [emit [blog-line blog <br>]]
    emit </blockquote>
    show-page title/search-page
]

show-edit: func [file /blog] [
    ; Show the blog edit form:
    validate-user
    either blog: load-blog file [
        emit-edit file blog/date blog/title safe-html blog/text
        show-page ["Edit blog " file ":"]
    ][
        emit-edit 0 now "" ""
        show-page "Submit a new blog:"
    ]
]

show-reply: func [blog] [
    ; Show the reply form. Note that the reply processing
    ; script is not part of this blog system.
    emit-reply reform ["Reply to Blog" blog]
    show-page title/feedback-page
]

make-blog-links: func [file /locals spot out] [
    ; Link to prior and next blogs in sequence:
    out: make string! 30
    spot: find load blog-dir to-file file
    if not spot [return ""]
    if not head? spot [
        file: spot/-1
        repend out [" || " link-blog file ["Prior Blog [" file "]"]]
    ] 
    if file: spot/2 [
        repend out [" || " link-blog file ["Next Blog [" file "]"]]
    ] 
    out
]

emit-edit: func [file date title text] [
    emit bind html-edit-form 'file
]

emit-reply: func [subject] [
    emit bind html-reply-form 'subject
]

;-- CGI Command Handler ------------------------------------------------------

read-cgi: func [
    "Read CGI data. Return data as string or NONE."
    /limit size "Limit to this number of bytes"
    /local data buffer
][
    if none? limit [size: 300000]
    switch system/options/cgi/request-method [
        "POST" [
            data: make string! 1020
            buffer: make string! 16380
            while [positive? read-io system/ports/input buffer 16380][
                append data buffer
                clear buffer
                if (length? data) > size [
                    print ["aborted - posting is too long:" length? data "limit:" size]
                    quit
                ]
            ]
        ]
        "GET" [data: system/options/cgi/query-string]
    ]
    any [data ""]
]

; Possible fields returned by CGI:
cgi-obj: context [
    view: find: edit: save: back: logon: date: title: text: reply: index: rebuild: none
]

if not blog-root [blog-path: none]
blog-count: 0 ; general blog page hit counter

do-cgi: has [cgi] [
    blog-count: 1 + any [attempt [load %blog-reads] 0]
    save %blog-reads blog-count
    cgi: construct/with decode-cgi read-cgi cgi-obj
    if cgi/view [show-blog cgi/view]
    if cgi/index [show-index]
    if cgi/reply [show-reply cgi/reply]
    if cgi/edit [show-edit cgi/edit]
    if cgi/find [show-search cgi/find]
    if cgi/save [
        show-blog save-blog cgi/save cgi/date cgi/title cgi/text
    ]
    if cgi/back [backup-blogs cgi/back]
    if cgi/rebuild [rebuild-blogs]
    show-main
]

if not exists? blog-dir [make-dir blog-dir]
if all [blog-root not exists? blog-root] [make-dir blog-root]

;-- Tests
;   Uncomment any of the lines below. But, dont' forget to comment it
;   back when you upload it back to your server.

;save-blog 0 now/date "Test" "This is a test"
;show-index
;show-main
;backup-blogs 0
;show-blog %0001
;show-edit %0001
;show-search "draw"

do-cgi ; start it (if no tests are uncommented)
