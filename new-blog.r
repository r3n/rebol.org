REBOL  [
    Title: "REBOL Blogger"
    Author: "Carl Sassenrath"
    Version: 1.4.1
    Date: 6-Oct-2006
    File: %new-blog.r
    Purpose: {
        The blog system written and used by Carl Sassenrath,
        REBOL's creator. This script will let you post and
        update blogs on your website using just a web browser.
        Generates summary and index pages, blog searches, etc.
        Extensible with Makedoc2 for more formatting options.
    }
    Dependencies: {
        For RSS, you will need emit-rss.r from Christopher Ross-Gill.
        For makedoc format, you need makedoc2.r from Carl Sassenrath.
        For a REBOL powered webserver, you will need ServeIt.r from Dirk Weyand.
    }
    License: {
        BSD. No warranties. Use at your risk.
        Do not remove credit to the authors.
        Do not change the official source URL.
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

; Blog.r Feature Summary:
;  1. Allows remote blogging via html forms.
;  2. Automatically builds main blog page.
;  3. Creates a dated index to all blogs.
;  4. Creates links to and between blogs.
;  5. Use your website's standard page template.
;  6. Supports ranked searches on blogs.
;  7. Provides a handy blog-content backup method.
;  8. Provides a form for feedback (but feedback system
;     is not a standard part of this blog.r script).
;  9. No database engine is needed.
; 10. Optionally generates static blog pages. [V1.3.0]
; 11. Supports multiple blogs on same site. [V1.3.0]
; 12. Supports rss-feeds [V1.4.0]
; 12. Supports comments on each blogging article [V1.4.1]
; 13. Works now smoothly with Serve-It! v2.7.4! 
;     All modifications of Carls Blogger script are marked with ; (TGD) ;
;     Download Serve-It! @ http://www.TGD-Consulting.de/Download.html#ServeIt 

; Installation: (only step 1 is still necassary for the usage with Serve-It!)
;  1. Upload this script to your CGI script directory.
;  2. Verify that you have a copy of REBOL/Core on your server.
;  3. Add a top line to point to REBOL/Core. Something like:
;     #!/usr/bin/rebol -cs
;  4. Change permissions (chmod 755) for blog.r to let it run.
;  5. Test it from a browser. If it has errors, you may need to
;     create the blog-dir dir and blog-reads file manually then
;     give them proper permissions (chmod 777 or 666). Be careful.
;  Read http://www.rebol.com/docs/cgi2.html for details.

cgi-obj: system/options/cgi

; (TGD) ; ;-- Special shortcut needed to fetch source code text:
; (TGD) ; if cgi-obj/request-method = "GET" [
; (TGD) ;    cgi: decode-cgi cgi-obj/query-string
; (TGD) ;    if find cgi to-set-word 'get-source [
; (TGD) ;        print "content-type: text/plain^/"
; (TGD) ;        print read %blog.r  ; use REBOL read url to save it
; (TGD) ;        quit
; (TGD) ;    ]
; (TGD) ; ]
; (TGD) ; This is handled within do-cgi now, see below.

; (TGD) ; print "content-type: text/html^/" ; activate web server content output

;-- Mezz Functions -----------------------------------------------------------    ; (TGD) ;
                                         ; (TGD) ;
if not value? 'attempt [                 ; (TGD) ;
    attempt: func [                      ; (TGD) ;
        blk [block!]                     ; (TGD) ;
        /local rc                        ; (TGD) ;
    ][                                   ; (TGD) ;
        if error? rc: try blk [rc: none] ; (TGD) ;
        return rc                        ; (TGD) ;
    ]                                    ; (TGD) ;
]                                        ; (TGD) ;
if not value? 'remove-each [             ; (TGD) ;
    remove-each: func [                  ; (TGD) ;
       'word [word! block! get-word!]    ; (TGD) ;
       data [series!]                    ; (TGD) ;
       body [block!]                     ; (TGD) ;
       /local i                          ; (TGD) ;
    ][                                   ; (TGD) ;
       i: 1                              ; (TGD) ;
       foreach :word copy data compose [ ; (TGD) ;
          either (body) [                ; (TGD) ;
            remove at data i             ; (TGD) ;
          ] [                            ; (TGD) ;
            i: i + 1                     ; (TGD) ;
          ]                              ; (TGD) ;
       ]                                 ; (TGD) ;
       data                              ; (TGD) ;
    ]                                    ; (TGD) ;
]                                        ; (TGD) ;

remote-ip: attempt [to-tuple cgi-obj/remote-addr]

;-- Configuration ------------------------------------------------------------

; Automatically detect when running on client in test mode.
; (Causes the tested page to be displayed in the browser.)
test-mode: not cgi-obj/request-method

; The website URL where your blog is located:
; Example: blog-site: http://www.rebol.net
blog-site: http://www.TGD-Consulting.de            ; (TGD) ;

; Absolute path to the blog CGI script on your server. You can change this
; if you want more than one REBOL blog on your web site.
; Example: blog-cgi: %/cgi-bin/blog.r
blog-cgi: %/cgi-bin/new-blog.r            ; (TGD) ;

; Full blog URL (you don't normally need to change this):
blog-url: blog-site/:blog-cgi

; Where raw blog text files are stored relative to this script:
; Example: blog-dir: %blogs/
blog-dir: %../blog/blogs/

; Where blog HTML pages are cached after they are generated.
; This should be under the root directory of your website.
; Make sure it has permissions to allow CGI file writing.
; Set this to NONE if you always want dynamic (CGI) pages.
; Example: blog-root: %../html/blogs/
blog-root: %../blog/html/

; The URL path to the above cache directory:
blog-path: %/blog/html/
blog-active: false  ; always use CGI to view blog

; The name of the main blog file/page within the above cache:
main-file: %blog-index.html

; File that holds the blog access counter:
blog-counter: %blog-reads

; An optional RSS feed file for the blog. Relative to blog-root
; above. Requires "Emit RSS" script from Christopher Ross-Gill.
rss-file: %blog-rss.xml

rss-url: join blog-site %/blog/html/rss.html

full-rss: true ; The entire article goes into RSS

; How many blogs are printed on the main page:
max-blogs: 3

; How many blogs are indexed at the bottom of the main page:
max-links: 10

; Where comment files are stored relative to this script:
; Example: blog-dir: %blog-cmts/
cmts-dir: %../blog/blog-cmts/
cmts-log: cmts-dir/log.r

; The blog author/admin IP address. Only this address gets to post.
; If your client uses dynamic IP, then this will not work and you
; will need to use a username/pass with cookies to protect your blog.
admin-ip: any [attempt [load %admin-ip] 192.168.1.1]
if string? admin-ip [admin-ip: to-tuple admin-ip] ; Tuple, not a string!

; The name of the blogger:
author: "Your Name Here"
author-title: "Your Title Here"
author-email: "no-spam@Your.Domain"

; IMG source link to author's photo location:
photo-file: %/photos/you.jpg
photo-text: "You at ..."
photo-link: %/photos/youat.jpg

; The name of the organization:
organization: "Your Company Here"

; Copyright name:
copyright: reform [author now/year]

; The titles of generated pages:
title: context [
    main-page:   "Your Name's Blog"
    index-page:  "Complete Index of Your Name Blogs:"
    search-page: "Results of Search:"
    feedback-page: "Send Feedback to Your Name"
]

; The meta decscription needed for search engines:
meta-description: trim/lines {
    Comments and ideas provided by Your Name via the
    REBOL Blogger.
}

; The purpose of the blog ; (TGD) ;
purpose: meta-description ; (TGD) ;

; Some links to other sites, blogs, etc. [URI Description]     ; (TGD) ;
links: [                                                       ; (TGD) ;
  http://www.rebol.net "The REBOL Developer Network"           ; (TGD) ;
  http://www.rebol.net/cgi-bin/r3blog.r "REBOL 3.0 Front Line" ; (TGD) ;
]                                                              ; (TGD) ;

; Blog page contents can be formatted with makedoc2 allowing nicer
; formatting of examples, etc. If the file below is not found, the
; default formatter will be used (just paragraph separation).
makedoc-script: %makedoc2.r

; Automatically detect when running on client in test mode.
; (Causes the tested page to be displayed in the browser.)
test-mode: not cgi-obj/request-method

; Where the official version of the blog.r source is stored:
source-url:     http://www.rebol.net/cgi-bin/blog.r?source=1
get-source-url: http://www.rebol.net/cgi-bin/blog.r?get-source=1

; Reject comments that include any of these strings (unless admin posted):
comment-restrict: reduce [
    to-string #{6675636B}
    to-string #{73686974}
    to-string #{766961677261}
]
comment-name-restrict: join comment-restrict [
    "sassenrath"
]
; Reject comment spammer,                              ; (TGD) ;
comment-max: 20 ; only 20 comments are allowed per day ; (TGD) ;

;-- HTML Templates -----------------------------------------------------------
;
; If you want to, you can cut and paste these into most HTML page editors to
; help revise them to get what you want. Just be sure to keep the {} braces.

; The name of the HTML template used for the look & feel. Fields within this
; template use the standard $variable format. See show-page function below.
blog-template: %blog-template.html

; The default HTML template if the above file cannot be found. This also shows
; the variable format needed to create your own blog-template.html file:
html-template: {
    <html>
    <!--page generated by rebol-->
    <head><title>$title</title>
    <link rel="alternate" type="application/rss+xml" href="/article/carl-rss.xml" title="Carl's REBOL Blog">
    <style type="text/css">
    body, p, td {font-family: arial, sans-serif, helvetica; font-size: 10pt;}
    h1 {font-size: 14pt;}
    h2 {font-size: 12pt; color: #2030a0; width: 100%; border-bottom: 1px solid #c09060;}
    h3 {font-size: 10pt; color: #2030a0;}
    tt {font-family: "courier new", monospace, courier; font-size: 9pt; color: darkgreen;}
    pre {font: bold 10pt "courier new", monospace, console;
        background-color: #f0f0f0; padding: 16px; border: solid #c0c0c0 1px;}
    .output {color: #006000}
    .note {background-color: #F0F080; width: 100%; padding: 16px; border: solid #a0a0a0 1px;}
    .title {Font-Size: 16pt; Font-Weight: bold;}
    .offset {text-align: right; width: 1.5in}
    .label {Width: 65px; Font-Weight: Bold; Margin-Top: 3px; Margin-bottom: 10px;
    Text-Align: Right; Vertical-Align: Top;}
    </style>
    </head>
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
    <a href=http://www.rebol.com>Blogger by REBOL</a> - <a href=http://www.TGD-Consulting.DE/Download.html#ServeIt>Serve-It! by TGD-Consulting</a></td></tr>
    </table></center></body></html>
}

; The HTML boilerplate used at the top of the first page:
html-main-boiler: [{
    <form action="} blog-cgi {" method="get">
    <table border=0 cellspacing=1 cellpadding=3>
    <tr>
    <td width=32></td>
    <td width=119 valign=top><a href="} photo-link {">}
    {<img src="} photo-file {" alt="} photo-text {" border=1></a></td>
    <td valign=top>
    <b>} author ", " author-title {
    <br>} organization {</b>}
    {<br><a href="} blog-url {?reply=0">Private feedback</a>}
    ;{<p>Updated } date/date " " to-GMT date
    {<p> } blog-count { visits since } either find get-modes blog-counter 'file-modes 'creation-date [first parse form get-modes blog-counter 'creation-date "/"]["4-Jan-2005"] ; (TGD) ; init date of counter  
    {<p><a href="} rss-url {"><img src="/graphics/rss.gif" width=36 height=14 border=0 alt="RSS"></a>}
    ;<br>[<a href="} blog-url {?index=0">Index of Prior Blogs</a>]
    {<p>Search: <input type=text size=25 name=find>
    </td>
    <td valign=top>
    <b>Purpose:</b>
    <br>} purpose      ; (TGD) ;
    {

    <p><b>Also Visit:</b>
    } make-links links ; (TGD) ;
    {

    <p><b>Most Recent Comments:</b>
    <br>} recent-comments {
    </td>
    </tr></table></form><p>
}]

; The HTML boilerplate used at the top of each separate blog page:
html-blog-boiler: [{
    <form action="} blog-cgi {" method="get">
    <table border=0 cellspacing=1 cellpadding=3>
    <tr><td width=32></td><td>
    <b>} author ", " author-title {
    <br>} organization {
    <br>} date/date " " to-GMT date {</b>
    <br>Article #} file {</b>
    <br><span style="color: #808080">
    <a href="} blog-url {"><b>Main page</b></a>
    || <a href="} blog-url {?index=0">Index</a>} make-blog-links file
    { || } make-comment-link blog
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
    <form action="http://www.rebol.com/cgi-bin/feedback/post.r" method="post">
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

html-comment-form: [{
    <form action="} blog-cgi {" method="post">
    <table border="0" cellpadding="2" cellspacing="1" width="100%">
    <tr>
    <td width="87"><p align="right"><b>Name:</b></td>
    <td><input type="text" name="name" value="$name" size="46"></td>
    </tr><tr>
    <td width="87" valign="top"><p align="right"><b><br>Comment:</b></td>
    <td><textarea name="text" rows="8" cols="58">$msg</textarea></td>
    </tr><tr>
    <td width="87">&nbsp;</td>
    <td>
    <input type="submit" name="Cancel" value="Cancel">
    <input type="submit" name="Preview" value="Preview" tabindex="10">
    $more
    </td>
    </tr><tr>
    <td width="87" height="25">&nbsp;</td>
    <td><i>Note: HTML tags allowed for:} tags-list {</i></td>
    </tr>
    </table>
    <input type=hidden name=cmt value=} file {>
    </form>}
]

button-for-post: <input type="submit" name="Post" value="Post">

;-- Utility Functions --------------------------------------------------------

abort: false   ; (TGD) ; quit shutdowns REBOL based Servers
html: make string! 8000
emit: func [data] [repend html data]

joins: func [data] [to-string reduce data]

optional: func [cond block] [
    ; Returns either the block contents or empty string:
    either cond block [""]
]

limit: func [size str] [
    either (length? str) > size [copy/part str size][str]
]

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
    optional date/time [
        date: fourth date - date/zone
        date/3: 0 ; remove seconds
        reform [date "GMT"]
    ]
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
    if all [admin-ip remote-ip <> admin-ip] [
        show-error "Permission denied."
    ]
]

filter-tags: func [
    "Filter HTML to only allow specific tags."
    page [string!]
    /local block
][
    init-filter-tags
    block: load/markup page
    remove-each item block [
        if tag? item [
            all [
                not find item #"<" ; No hiding evil tags in good tags
                not any [
                    find tags-allowed item
                    ; Allow </tag>:
                    all [item/1 = slash  find tags-allowed next item]
                    foreach tag ext-tags [
                        if find/match item tag [break/return true]
                    ]
                ]
            ]
        ]
    ]
    replace/all to-string block #"@" "(at)"
]

init-filter-tags: does [
    ; Globals:
    if value? 'tags-allowed [exit]
    tags-allowed: [<b> <i> <u> <li> <ol> <ul> <font> <a> <p> <br> <pre> <blockquote>]
    tags-list: make block! length? tags-allowed
    foreach tag tags-allowed [append tags-list to-string tag]
    tags-list: form tags-list
    ext-tags: make block! length? tags-allowed ; E.g. <font color="red">
    foreach tag tags-allowed [append ext-tags append to-string tag " "]
]

nice-date: func [
    "Convert date/time to a friendly format."
    date [date!]
    /local n day time diff
][
    n: now
    time: date/time
    diff: n/date - date/date
    if diff < 2 [return "Today"]
    if diff < 3 [return "Yesterday"]
    if diff < 7 [return "This week"]
    return ""
]

find-any: func [
    "Search a string for a variety of substrings."
    string
    block
][
    foreach item block [
        if find/any string item [return item]
    ]
    none
]


;-- HTML Page Output ---------------------------------------------------------

show-page: func [title /edit link /main /build file /local template tag] [
    ; Show page thru CGI or locally in browser (for testing)
    template: attempt [read blog-template] ; fails for NONE
    if not template [template: trim/auto copy html-template] ; use default
    if all [main meta-description] [
        tag: build-tag [meta name "description" content (meta-description)]
        attempt [insert insert find/tail template <head> newline tag]
    ]
    title: joins title
    replace/all template "$title" title
    if build [edit: true link: file]
    if not link [link: 'new]
    tag: rejoin [{<a href="} blog-url {?edit=} link {">Edit</a>}]
    replace template "$edit" tag
    replace/all template "$date" now/date
    replace/all template "$source" source-url
    replace template "$content" html
    if blog-root [
        if edit [write join blog-root/:link ".html" template]
        if all [main remote-ip = admin-ip][
            ; Patch for Google indexing problem:
            write blog-root/:main-file template
        ]
    ]
    if build [exit] ; just an update
    either test-mode [
        write %temp-page.html template
        browse %temp-page.html
    ][
        print template
    ]
    abort: true ; (TGD) ;
; (TGD) ;    quit
]

show-error: func [msg] [
    ; Output an error page:
    emit <b>
    emit msg ; (do not combine)
    emit </b>
    show-page "Blogger Error:"
]

;-- Blog File Handling -------------------------------------------------------

blog-obj: context [file: date: title: text: cmt: comments: none]

load-blog: func [file /local blog] [
    if attempt [
        blog: load/all join blog-dir file
; (TGD) ;        blog: construct/with blog blog-obj
        blog: make blog-obj blog ; (TGD) ;
        all [
            blog/file: file
            date? blog/date
            string? blog/text
        ]
    ][
        load-comment blog
        blog
    ]
]

save-blog: func [file date title text /local blog files] [
    validate-user
    if not abort [ ; (TGD) ;
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
    build-rss-feed
    file
    ] ; (TGD) ;
]

find-blog: func [blog strs /local rank text][
    ; Ranks blog contents during a search:
    rank: 0
    foreach str strs [
        if find/any blog/title str [rank: rank + 4]
        text: blog/text
        while [text: find/any/tail text str] [text: copy text rank: rank + 1] ; (TGD) ; avoid infinte loop
    ]
    rank
]

backup-blogs: func [start /local files] [
    ; This backs up the blog on a remote site so you don't lose them.
    ; The remote site should CGI with blog.r?back=n where n the start.
    ; This can easily be done with a few lines of REBOL for backup.
    validate-user
    if not abort [ ; (TGD) ;
    system/options/binary-base: 64
    start: to-integer start
    out: copy []
    foreach file sort load blog-dir [
        if (to-integer file) >= start [
            repend out [mold file compress read join blog-dir file]
        ]
    ]
    print out
    abort: true
; (TGD) ;    quit
    ]
]

rebuild-blogs: does [
    ; Rebuild all cached HTML blog pages. To run this, browse
    ; with a URL like: http://.../cgi-bin/blog.r?rebuild=0
    validate-user
    if all [not abort blog-root] [ ; (TGD) ;
        foreach file sort load blog-dir [
            clear html
            print ["Building:" file <br>]
            show-blog/build file
        ]
        build-rss-feed
        print "Done"
        abort: true
; (TGD) ;    quit
    ]
]

save-comment: func [file name msg] [
    write/append join cmts-dir file repend mold compose [
        date (now)
        name (name)
        ip (remote-ip)
        text (msg)
    ] [newline newline]
]

load-comment: func [blog] [
    blog/comments: attempt [load/all join cmts-dir blog/file]
]

note-comment: func [file sum] [
    write/append cmts-log reform [file now sum remote-ip newline]
]

load-comment-log: has [log list str] [
    log: attempt [load cmts-log]
    if not log [recent-comments: "" exit]
    log: head reverse log
    list: make block! 10
    foreach [ip hash time file] log [
        if greater? length? list 9 [break]
        if not find list file [repend list [file time]]
    ]
    recent-comments: make string! 100
    foreach [file time] list [
        file: file-num file
        repend recent-comments [{<a href="} blog-cgi {?view=} file {#comments">} file </a> " "]
    ]
]

abuse?: func [rip sum text /local log tim count] [
    count: 0
    while [text: find/tail text "http://"] [count: count + 1]
    if count > 3 [return true]
    log: attempt [load cmts-log]
    if log [
        tim: now
        count: 0
        log: head reverse log
        foreach [ip hash time file] log [
            if hash = sum [return true] 
            if all [
                rip = ip
; (TGD) ;                (difference tim time) < 24:00 ; doesn´t work on REBOL/View 1.2.1.1.1
                (seconds tim time) < 86400     ; (TGD) ; using Serve-It! seconds func instead
; (TGD) ;                (count: count + 1) > 20
                (count: count + 1) > comment-max ; (TGD) ; comment spammer
            ][
                return true
            ]
        ]
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
        either all [blog-path not blog-active] [
            join blog-path/:value ".html"
        ][
            join blog-url ["?view=" value]
        ]
        {">} joins text </a>
    ]
]

blog-line: func [blog] [
    ; Generates a full blog summary line:
    to-string reduce [
        <tr> <td width="20%" align=right> blog/date/date </td>
        <td>
        " - " <b> link-blog blog/file blog/title </b>
        " [" blog/file "] "
        optional exists? join cmts-dir blog/file [
            make-comment-link/short blog
        ]
        </td></tr>
        newline
    ]
]

format-text: func [text] [
    ; Formats text for output:
    either exists? makedoc-script [
        ; Use the Makedoc2 text-to-html formatter:
        if not find text "^/^/###" [text: append copy text "^/^/###"]
        do/args makedoc-script 'load-only
        text: scan-doc/options text [no-title]
        second gen-html/options text [no-title no-toc no-nums no-indent no-template old-tags]
    ][
        replace/all copy text "^/^/" "^/<p>"
    ]
]

make-comment-link: func [blog /short] [
    to-string reduce [
        {<a href="} blog-cgi {?view=} blog/file {#comments">}
        <font color="#227B22">
        either blog/comments [length? blog/comments]["Post "]
        pick [{ Comments}{ Cmts}] not short
        </font>
        </a>
    ]
]

emit-comment-link: func [blog] [
    emit [
        <p align="right"><font size="1"> make-comment-link blog </font></p>
    ]
]

emit-comment-form: func [file name message /post /local frm][
    init-filter-tags
    frm: joins bind html-comment-form 'file
    replace frm "$name" name
    replace frm "$msg" message
    replace frm "$more" optional post [button-for-post]
    emit frm
]

format-msg: func [str] [
    replace/all copy str "^/^/" "^/<p>"
]

emit-comments: func [blog /local n] [
    emit {<a name="comments"></a>}
    if block? blog/comments [
        emit {<h2>Comments:</h2><p><table width="100%" border="0" cellspacing="1" cellpadding="8" bgcolor="silver">}
        n: true
        foreach cmt blog/comments [
            emit [
                <tr>
                either cmt/name = author [
                    <td width="10%" valign="top" nowrap bgcolor="#FFF0A0">
                ][
                    <td width="10%" valign="top" nowrap bgcolor="white">
                ]
                <b> limit 24 cmt/name </b><br>
                <font size="1" color="gray"> cmt/date/date " " cmt/date/time</font></td>
                either n: not n [
                    <td width="90%" valign="top" bgcolor="#f4f4f4">
                ][
                    <td width="90%" valign="top" bgcolor="#e0f0e0">
                ]
                newline
                format-msg filter-tags cmt/text
                </td></tr>
            ]
        ]
        emit </table>
    ]
    emit {<h2>Post a Comment:</h2><p>}
    emit-comment-form blog/file "" ""
]

preview-comment: func [file name message] [
    message: filter-tags message
    emit [
        {<h2>Verify Your Comment:</h2>}
        {Please check that your comment is correct. It cannot be
        changed once it is posted.<p>}
        {<table width="100%" border="0" cellspacing="1" cellpadding="8" bgcolor="silver">}
        <tr>
        <td width="10%" valign="top" nowrap bgcolor="white"><b> limit 24 name </b><br>
        <font size="1" color="gray">now/date " " now/time</font></td>
        <td width="90%" valign="top" bgcolor="#f0f0f0"> newline
        format-msg message
        </td></tr>
        </table>
        {<h2>Make Corrections and/or Post It:</h2>}
    ]
    emit-comment-form/post file name message
]

show-blog: func [file /build /local blog date] [
    ; Show a single blog page. If /build is set, then only build it (not show it).
    ; If /build is not set, then show the page (with comments).
    if integer? file [file: file-num file]
    blog: load-blog file
; (TGD) ;    if not blog [show-error ["Blog " file " was not found"]]
    either not blog [show-error ["Blog " file " was not found"]] [ ; (TGD) ;
    date: blog/date
    emit bind html-blog-boiler 'blog
    emit format-text blog/text

    emit-comment-link blog
    show-page/build blog/title file
    emit-comments blog
    if not build [show-page join "Comments on: " blog/title file]
    ] ; (TGD) ;
]

show-main: has [n files blogs blog date] [
    ; Show the main blog page:
    date: now
    load-comment-log
    emit bind html-main-boiler 'date
    files: sort/reverse load blog-dir
    blogs: copy []
    emit [
        <h2> "Recent Articles:" </h2>
        <table border=0 cellpadding=0 cellspacing=1>
    ]
    foreach file files [
        if blog: load-blog file [
            append blogs blog
            emit blog-line blog
            if (length? blogs) > max-links [break]
        ]
    ]
    emit [
        {<tr><td width="20%" align="right">Contents</td>}
        {<td>&nbsp;- <b><a href="} blog-cgi {?index=0">Index of all articles.</a></b></td></tr>}
    ]
    emit </table>
    n: 1
    foreach blog blogs [
        if n > max-blogs [break]
        emit [<br><h2> title-blog blog " [" link-blog blog/file blog/file "]" </h2>]
        emit format-text blog/text
        emit-comment-link blog
        n: n + 1
    ]
    emit [
        {<p><b><i><a href="} blog-cgi {?index=0">View index of all articles...</a></i></b>}
    ]
    show-page/main title/main-page
]

show-index: has [blog] [
    ; Show the blog index page:
    emit [
        {<form action="} blog-cgi {" method="get"><p>}
        "Search - " <input type=text size=25 name=find></p>
        </form>
    ]
    emit <table border="0" cellpadding="1" cellspacing="1">
    foreach file sort/reverse load blog-dir [
        if blog: load-blog file [emit blog-line blog]
    ]
    emit </table>
    show-page title/index-page
]

show-search: func [text /local rank list blog] [
    ; Show the results of a blog search, listed by search-hit rank:
    text: parse text none
    list: copy []
    foreach file sort/reverse load blog-dir [
        if blog: load-blog file [
            rank: find-blog blog text
            if rank > 0 [repend list [rank blog]]
        ]
    ]
    sort/reverse/skip list 2
    emit [
        "The search found " (length? list) / 2 " blogs (listed by relevance):"
        <p>
    ]
    emit <table border="0" cellpadding="1" cellspacing="1">
    foreach [rank blog] list [emit blog-line blog]
    emit </table>
    show-page title/search-page
]

show-edit: func [file /blog] [
    ; Show the blog edit form:
    validate-user
    if not abort [ ; (TGD) ;
    either blog: load-blog file [
        emit-edit file blog/date blog/title safe-html blog/text
        show-page ["Edit blog " file ":"]
    ][
        emit-edit 0 now "" ""
        show-page "Submit a new blog:"
    ]
    ] ; (TGD) ;
]

show-reply: func [blog] [
    ; Show the reply form. Note that the reply processing
    ; script is not part of this blog system.
    if blog = "0" [blog: ""]
    emit-reply reform ["Reply to blog" blog]
    show-page title/feedback-page
]

make-links: func [blk /locals out] [                     ; (TGD) ;
    ; Link to other sites, blogs ...                     ; (TGD) ;
    out: make string! 30                                 ; (TGD) ;
    foreach [URI txt] blk [                              ; (TGD) ;
       repend out [{<br><a href="} URI {">} txt {</a>}]  ; (TGD) ;
    ]                                                    ; (TGD) ;
    out                                                  ; (TGD) ;
]                                                        ; (TGD) ;

make-blog-links: func [file /locals spot out] [
    ; Link to prior and next blogs in sequence:
    out: make string! 30
    spot: find sort load blog-dir to-file file
    if not spot [return ""]
    if not head? spot [
        file: spot/-1
        repend out [" || " link-blog file ["Prior Article [" file "]"]]
    ]
    if file: spot/2 [
        repend out [" || " link-blog file ["Next Article [" file "]"]]
    ] 
    out
]

emit-edit: func [file date title text] [
    emit bind html-edit-form 'file
]

emit-reply: func [subject] [
    emit bind html-reply-form 'subject
]

show-source: has [val] [
    ; Source code archive
    emit [{
        <h2>Powered By REBOL</h2>
        <b>This blogger is powered entirely by REBOL/}
        system/product { version } system/version 
; TGD ;        The source code is only } round (size? %blog.r) / 1024 { KB.</b>
        {. The source code is only } to integer! add 0.5 (size? %blog.r) / 1024 { KB.</b>
        <p>View } {<a href="} blog-url {">} title/main-page {</a> as an example blog.
        <p><h2>Current Source Code Info</h2><pre>}
    ]
    foreach word next first system/script/header [
        if val: system/script/header/:word [
            emit [word ": " val newline]
        ]
        html: detab html
    ]
    emit [{</pre>
        <h2>Download Link</h2>
        Click here: <b><a href="} get-source-url
        {">Download REBOL Blogger Source</a></b>
        <p>To run the REBOL blogger, you will need to grab a copy of
        REBOL/Core from the REBOL.com web site. It is small, fast,
        does not require installation, and is free for all uses.}
    ]
    show-page "Blogger Source Code"
]

;-- RSS Feed (optional) ------------------------------------------------------

build-rss-feed: func [
    "Build an RSS feed file for most recent blogs"
    /local files out blog content
][
    if any [not rss-file not exists? rss-file] [exit]  ; (TGD) ;
    files: sort/reverse load blog-dir
    clear at files max-links
    out: compose/deep [
        channel [
            title (title/main-page)
            link (blog-url)
            description (meta-description)
            language "en-us"
            copyright (copyright)
            generator "REBOL Messaging Language"
        ]
    ]
    foreach file files [
        if blog: load-blog file [
            content: load/markup either full-rss [
                blog/text
            ][
                trim/lines copy/part blog/text any [
                    find blog/text "^/^/" tail blog/text
                ]
            ]
            remove-each tag content [tag? tag]
            content: to-string content
            append out compose/deep [
                item [
                    title (blog/title)
                    link (join blog-site [blog-path file ".html"])
                    author (joins [author " &lt;" author-email "&gt;"])
                    pubdate (blog/date)
                    description (content)
                ]
            ]
        ]
    ]
    do %emit-rss.r
    if blog-root [
        write blog-root/:rss-file emit-rss out
    ]
]

;-- CGI Command Handler ------------------------------------------------------

read-cgi: func [
    "Read CGI data. Return data as string or NONE."
    /limit size "Limit to this number of bytes"
    /local data buffer
][
    if none? limit [size: 300000]
    switch cgi-obj/request-method [
        "POST" [data: system/script/args] ;  (TGD) ; Serve-It! sends POST-data via system/script/args to the CGI-script
; (TGD) ;            data: make string! 1020
; (TGD) ;            buffer: make string! 16380
; (TGD) ;            while [positive? read-io system/ports/input buffer 16380][
; (TGD) ;                append data buffer
; (TGD) ;                clear buffer
; (TGD) ;                if (length? data) > size [
; (TGD) ;                    print ["aborted - posting is too long:" length? data "limit:" size]
; (TGD) ;                    quit
; (TGD) ;                ]
; (TGD) ;            ]
; (TGD) ;        ]
        "GET" [data: cgi-obj/query-string]
    ]
    any [data ""]
]

; Possible fields returned by CGI:
cgi-fields: context [
    view: find: edit: save: date: title: text: reply: index: none
]

if not blog-root [blog-path: none]
blog-count: 0 ; general blog page hit counter

do-cgi: has [cgi] [
    ; Main CGI command handler.
    ; (It's getting to be time to rewrite it.)
    blog-count: 1 + any [attempt [load blog-counter] 0]
    save blog-counter blog-count
; (TGD) ;    cgi: construct/with decode-cgi read-cgi cgi-fields
    cgi: make cgi-fields decode-cgi read-cgi                            ; (TGD) ;
    if all [not abort in cgi 'get-source] [                             ; (TGD) ;
        print compress read second split-path blog-cgi                  ; (TGD) ;
        clear ct                    ; set Serve-It! content-type        ; (TGD) ;
        insert ct "text/plain"      ; callback to appropriate type      ; (TGD) ;
; (TGD) ;       print read %blog.r  ; use REBOL read url to save it     ; (TGD) ;
       abort: true                                                      ; (TGD) ;
    ]                                                                   ; (TGD) ;
    if all [not abort found? cgi/view] [show-blog to-integer cgi/view]  ; (TGD) ;
    if all [not abort found? cgi/index] [show-index]                    ; (TGD) ;
    if all [not abort found? cgi/reply] [show-reply cgi/reply]          ; (TGD) ;
    if all [not abort found? cgi/edit] [show-edit cgi/edit]             ; (TGD) ;
    if all [not abort found? cgi/find] [show-search cgi/find]           ; (TGD) ;
    if all [not abort found? cgi/save] [                                ; (TGD) ;
        show-blog save-blog cgi/save cgi/date cgi/title cgi/text        ; (TGD) ;
    ]                                                                   ; (TGD) ;
    if all [not abort in cgi 'cmt] [                                    ; (TGD) ;
        if not in cgi 'cancel [
            if any [
                empty? cgi/cmt
                empty? cgi/name
                empty? cgi/text
            ][
                show-error "Missing field in form. Go back and try again."
            ]
            if all [not abort (length? cgi/text) > 4000] [ ; (TGD) ;
                show-error "Message is too long. Go back and trim it down."
            ]
            if all [not abort ; (TGD) ;
              any [ ; Qualify the comment id:
                find cgi/cmt #"/"
                not attempt [to-integer cgi/cmt]
                not exists? join blog-dir cgi/cmt
              ]
            ] [
                show-error "Invalid comment submission"
            ]
            if all [not abort find cgi/name "<"] [ ; (TGD) ;
                show-error "Tags not allowed in name field. Go back and change it."
            ]
            if all [
                not abort ; (TGD) ;
                find-any cgi/name comment-name-restrict
                admin-ip admin-ip <> remote-ip
            ][
                show-error "Restricted name. Go back and use your name."
            ]
            if all [not abort find-any cgi/text comment-restrict] [ ; (TGD) ;
                show-error "Restricted words found in comment."
            ]
        ]
        if all [not abort in cgi 'preview] [ ; (TGD) ;
            preview-comment cgi/cmt cgi/name cgi/text
            show-page "Preview"
            
        ]
        if all [not abort in cgi 'post] [
            sum: checksum/secure rejoin [cgi/name cgi/text cgi/cmt]
            either abuse? remote-ip sum cgi/text [ ; (TGD) ;
               show-error ["Duplicate posting or abuse detected from" remote-ip]
            ][
               save-comment cgi/cmt cgi/name cgi/text
               note-comment cgi/cmt sum
               show-blog cgi/cmt
            ]
        ]
    ]
    if all [not abort in cgi 'back] [backup-blogs cgi/back]      ; (TGD) ;
    if all [not abort in cgi 'rebuild] [rebuild-blogs]           ; (TGD) ;
    if all [not abort in cgi 'source] [show-source]              ; (TGD) ;
    if not abort [show-main ]                                    ; (TGD) ;
]

if not exists? blog-dir [make-dir/deep blog-dir]
if all [blog-root not exists? blog-root] [make-dir/deep blog-root]
if not exists? cmts-dir [make-dir/deep cmts-dir]

;-- Tests
;   Uncomment any of the lines below. But, dont' forget to comment it
;   back when you upload it back to your server.

;save-blog 2 now/date "Test" "This is a test"
;show-index
;show-main
;backup-blogs 0
;show-blog %0001
;show-edit %0001
;show-search "draw"
;show-source

do-cgi ; start it (if no tests are uncommented)
; (TGD) ;halt