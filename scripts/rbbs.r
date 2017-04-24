; (TGD) ; #!../rebol -cs
REBOL [
    Title: "RBBS - REBOL Bulletin Board Tutorial"
    File: %rbbs.r     ; (TGD) ;
    Version: 1.0.0
    Created: 14-Nov-2004
    Date: 25-Jan-2005
    Author: [
        "Carl Sassenrath"
        "Gregg Irwin"
        "Volker Nitsch"
        "Tom Conlin"
    ]
    Copyright: "REBOL Technologies"
    License: "BSD (www.opensource.org/licenses/bsd-license.php)"
    Web: http://www.rebol.com/docs/cgi-bbs.html
    Note: "Go to the above URL for the tutorial document."
    Purpose: "A CGI Web Bulletin Board / Message Board"                            ; (TGD) ;
    Needs: "Serve-It! or any other webserver featuring REBOL CGI-Scripts." ; (TGD) ;
    Library: [                                                                                               ; (TGD) ;
        level: 'intermediate
        platform: 'all
        type: [tool]
        domain: [cgi html http]
        tested-under: [view 1.2.1.1.1 on "AmigaOS" view 1.2.1.3.1 on "Windows 2000"]
        support: none
        license: 'BSD
        see-also: "Serve-It!, at http://www.TGD-Consulting.de/Download.html"
        ]
]

; (TGD) ; Modified by Dirk Weyand to work smoothly with Serve-It!,
; (TGD) ; the smart server-engine based on REBOL/View.
; (TGD) ; All modifications of the original script are marked with ; (TGD) ;
; (TGD) ; Download Serve-It! @ http://www.TGD-Consulting.de/Download.html#reblets 

; (TGD) ; print "content-type: text/html^/"

;-- Configuration Settings ---------------------------------------------------

config: context [

    title: "Simple REBOL Message Board"
    cgi-path: %/cgi-bin/rbbs.r

    base-dir:  %../rbbs/ ; (TGD) ; Document-Root
    topic-id: join base-dir %id.r
    topic-db: join base-dir %topics.db
    msg-dir:  join base-dir %messages/

    html-template: join base-dir %template.html
    html-form: join base-dir %form.html

    max-days: 60  ; delete msgs older than this if...
    max-msgs: 100 ; max messages is reached.

    msg-order: none ; or 'new-first for reverse order

    tags-allowed: [<b> <i> <p> <br> <pre> <blockquote> <a> <font>]

]

if not exists? config/msg-dir [make-dir/deep config/msg-dir]

;-- Various Utility Functions ------------------------------------------------

abort: false        ; (TGD) ; quit or halt shutdowns REBOL based Servers

attempt: func [     ; (TGD) ; function not implemented in REBOL/View 1.2.1.1.1
    {Tries to evaluate and returns result or NONE on error.}
    value][
    if not error? set/any 'value try :value [get/any 'value]]

remove-each: func [ ; (TGD) ; function not implemented in REBOL/View 1.2.1.1.1
    {Removes a value from a series for each block that returns TRUE.}
    'word [get-word! word! block!] {Word or block of words to set each time (will be local)}
    data [series!] "The series to traverse"
    body [block!] "Block to evaluate. Return TRUE to remove."
][
    while [not tail? data] [
       set word first data
       either do body [remove data] [data: next data]
    ]
    unset word
]

build-tag: func [ ; (TGD) ; fixed version of function implemented in REBOL/View 1.2.1.1.1
    "Generates a tag from a composed block."
    values [block!] "Block of parens to evaluate and other data."
    /local tag value-rule xml? name attribute value
][
    tag: make string! 7 * length? values
    value-rule: [
        set value issue! (value: mold value)
        | set value file! (value: replace/all copy value #" " " ")
        | set value any-type!
    ]
    xml?: false
    parse compose values [
        [
            set name ['?xml (xml?: true) | word!] (append tag name)
            any [
                set attribute [word! | url!] value-rule (
                    repend tag [#" " attribute {="} value {"}]
                )
                | value-rule (repend tag [#" " value])
            ]
            end (if xml? [append tag #"?"])
        ]
        |
        [set name refinement! to end (tag: mold name)]
    ]
    to tag! tag
]

seconds: func [ ; (TGD) ; difference function in REBOL/View 1.2.1.1.1 doesn´t support date!
    "Compute difference between dates in seconds." 
    a [date!] "first date" 
    b [date!] "second date"
] [
    b - a * 86400 + (to decimal! b/time) - (to decimal! a/time) + (a/zone/hour - b/zone/hour * 3600)
]

; If not in CGI environment, set Test-Mode.
test-mode: not system/options/cgi/request-method

system/options/binary-base: 64

html: make string! 5000
emit: func [data] [append repend html data newline]
href: func [data] [build-tag [a href (reduce data)]] ; href [name ".txt"]

encode-html: func [
    "Make HTML tags into HTML viewable escapes (for posting code)"
    text
][
    foreach [from to] ["&" "&amp;"  "<" "&lt;"  ">" "&gt;"] [
        replace/all text from to
    ]
]

;-- Nicely Format the Date ---------------------------------------------------

nice-date: func [
    "Convert date/time to a friendly format."
    date [date!]
    /local n day time diff
][
    n: now
    time: date/time
    diff: n/date - date/date
    if not day: any [
        if diff < 2 [
            time: to time! seconds date n
; TGD ;            time: difference n date
            time/3: 0
            return reform [time "hrs ago"]
        ]
        if diff < 7 [pick system/locale/days date/weekday]
    ][
        day: form date/date
        if n/date/year = date/date/year [clear find/last day #"-"]
    ]
    join day [<br> time " ET"]
]

;-- Read CGI Request ---------------------------------------------------------

read-cgi: func [
    "Read CGI data. Return data as string or NONE."
    /limit size "Limit to this number of bytes"
    /local data buffer
][
    if none? limit [size: 300000]
    switch system/options/cgi/request-method [
        "POST" [data: system/script/args] ;  (TGD) ; Serve-It! liefert POST-Data
; (TGD) ;                                 per system/script/args an das CGI-script
; (TGD) ;        "POST" [
; (TGD) ;            data: make string! 1020
; (TGD) ;            buffer: make string! 16380
; (TGD) ;            while [positive? read-io system/ports/input buffer 16380][
; (TGD) ;                append data buffer
; (TGD) ;                clear buffer
; (TGD) ;                if (length? data) > size [
; (TGD) ;                    print ["aborted - posting is too long:"
; (TGD) ;                        length? data "limit:" size]
; (TGD) ;                    quit
; (TGD) ;                ]
; (TGD) ;            ]
; (TGD) ;        ]
        "GET" [data: system/options/cgi/query-string]
    ]
    any [data ""] ; (TGD) ;
]

;-- Read HTML File Body ------------------------------------------------------

read-body: func [
    "Extract the body contents of an HTML file."
    html [file!]
][
    html: read html
    remove/part html find/tail find html "<BODY" ">"
    clear find html </BODY>
    html
]

;-- Send HTML Page to Browser ------------------------------------------------

show-page: func [
    "Merge template with title and contents, and output it."
    title    ; page title
    content  ; page contents
    /local template
][
    template: read config/html-template
    replace/all template "$title" title
    replace/all template "$date" now/date
    replace/all template "$version" system/script/header/version
    replace template "$content" content
    either test-mode [
        write %temp-page.html template
        browse %temp-page.html
; (TGD) ;        halt
    ][
        print template
; (TGD) ;        quit
    ]
    abort: true ; (TGD) ;
]

show-error: func [
    "Tell user about an error."
    block "Block to be formed."
][
    show-page "An Error Occurred..." reform block
]

;-- Filter HTML Tags ---------------------------------------------------------

filter-tags: func [
    "Filter HTML to only allow specific tags."
    page [string!]
    /local block extended
][
    block: load/markup page
    extended: make block! length? block
    foreach tag config/tags-allowed [append extended append to-string tag " "] 
    remove-each item block [
        if tag? item [
            not any [
                find config/tags-allowed item
                ; allow </tag>
                all [item/1 = slash  find config/tags-allowed next item]
                foreach tag extended [
                    if find/match item tag [break/return true]
                ]
            ]
        ]
    ]
    to-string block
]

;-- Emit the Web Form --------------------------------------------------------

emit-form: func [
    "Emit the submission form (for both topics and messages)."
    topic-id [integer! none!] ; Use NONE to allow topic input
    /local text type
][
    text: read-body config/html-form
    type: 'topic
    if topic-id [
        ; Remove subject field from the form:
        remove/part find text <tr> find/tail text </tr>
        ; Add a hidden field for the topic id:
        append text build-tag [input type hidden name id value (topic-id)]
        type: 'msg
    ]
    emit [
        build-tag [form action (config/cgi-path) method post]
        build-tag [input type hidden name cmd value (type)]
        text
        </form>
    ]
]

;-- Topic Functions ---------------------------------------------------------

; Each topic is given a unique ID number to identify it. The
; messages for a topic are stored in a file that uses that id
; number. A master topics.db file holds the list of topics
; as a block of blocks. Each block has the format:
; 
; [topic id create-date modified-date msg-count last-from]
; 
; Each time a new topic is created, it is added to the
; topics file. Each time a message is added, the topics file
; is updated to show the new mod-date and msg-count.

next-topic-id: func [
    "Create next topic id #"
    /local n
][
; TGD ;    save %id.r n: 1 + any [attempt [load config/topic-id] 0] 
    save config/topic-id n: 1 + any [attempt [load config/topic-id] 0] 
    n
] 

load-topics: does [any [attempt [load/all config/topic-db] []]] 

save-topics: func [data] [write config/topic-db mold/only data] 

add-topic: func [
    {Add a new topic. Store it in topic file. Return id.} 
    topic
][
    id: next-topic-id 
    write/append config/topic-db append remold [topic id now now 0 ""] newline
    id
] 

must-find-topic: func [
    "Return topic record or show an error"
    topic-id
][
    foreach topic load-topics [
        if topic/2 = topic-id [return topic]
    ]
    show-error "Invalid message topic. Contact the administrator."
    not abort
]

update-topic: func [
    "Update message status for topic"
    topic-id
    count "number of messages"
    name "last message from"
    /local topics
][
    topics: load-topics 
    foreach topic topics [
        if topic/2 = topic-id [
            topic/4: now
            topic/5: count
            if not topic/6 [append topic none]
            topic/6: name
            sort/reverse/compare topics 4
            save-topics topics
            exit
        ]
    ]
]

link-topic: func [
    "Create an HREF link to a message topic"
    topic-id
    /bookmark name
    /local path
][
    path: join config/cgi-path ["?cmd=msgs&id=" topic-id "&"]
    if bookmark [repend path [#"#" name]]
    href path
]

emit-topics: func [
    "Generate listing of all topics"
][
    emit [
        <table border=0 width="100%" cellpadding=4 cellspacing=1 bgcolor=silver> 
        <tr bgcolor=maroon>
        <td align=center><font color=white><b> "Msgs" </b></font></td>
        <td width=80%><font color=white><b> "Topic" </b></font></td>
        <td align=right nowrap><font color=white>
        <b> "Last Posting" </b>
        </font></td>
        <td><font color=white><b> "From" </b></font></td>
        </tr>
    ]
    foreach topic load-topics [
        emit [
            <tr bgcolor=white> 
            <td><p align=center> topic/5 </p></td> 
            <td width=80%> link-topic topic/2 <b> topic/1 </b> </a> </td> 
            <td align=right nowrap> nice-date topic/4 </td> 
            <td> topic/6 </td> 
            </tr>
        ]
    ] 
    emit </table>
]

;-- Message Functions --------------------------------------------------------

;  Each message file is stored under the topic id number for it.
;  Message records have the format:
;
;  [name email date message]
;
;  The message is stored as binary to avoid any possible problems
;  related to delimiting it as a REBOL value.

load-messages: func [
    "Load messages for a specific topic."
    topic-id
][
    any [attempt [load/all config/msg-dir/:topic-id] []]
] 

save-messages: func [
    "Save messages for a specific topic."
    topic-id
    messages
][
    write config/msg-dir/:topic-id mold/only messages
] 

add-message: func [
    {Add a new message.} 
    topic-id
    name
    email
    message
][
    write/append config/msg-dir/:topic-id append
        remold [name email now to-binary message] newline
]

purge-messages: func [
    "If message limit is exceeded, purge older messages."
    msgs
    /local today
][
    if (length? msgs) > config/max-msgs [
        today: now
        remove-each msg msgs [
            msg/3/date + confg/max-days < today
        ]
        save-messages topic-id msgs
    ]
]

obscure-email: func [
    "Make email more difficult for harvesters"
    email
][
    either any-string? email [replace email #"@" <br>][""]
]

emit-messages: func [
    "Generate listing of messages"
    msgs "block of messages"
][
    emit [
        <table border=0 width="100%" cellpadding=3 cellspacing=1 bgcolor=silver>
        <tr bgcolor=navy>
        <td><font color=white><b> "Sender" </b></font></td>
        <td width=80%><font color=white><b> "Message" </b></font></td>
        <td align=right nowrap><font color=white><b> "When Sent" </b>
        </font></td>
        </tr>
    ]
    foreach msg msgs [
        emit [
            <tr bgcolor=white>
                <td nowrap><b> msg/1 </b><br><i> obscure-email msg/2 <i></td> 
                <td width=80%> to-string msg/4 </td>
                <td align=right nowrap> nice-date msg/3 </td>
            </tr> 
        ]
    ] 
    emit </table>
] 

list-messages: func [
    "Emit message list with form. Return title."
    topic-id
    /update "Update message count"
    /local rec
][
    if rec: must-find-topic topic-id [ ; (TGD) ;
    emit [
        <b>
        href config/cgi-path "Return to Topics" </a> " | "
        href #end "Go to End" </a> " | "
        link-topic topic-id "Refresh" </a>
        </b><p>
    ]
    msgs: load-messages topic-id
    if all [update not empty? msgs] [
        purge-messages msgs
        update-topic topic-id length? msgs first last msgs
    ]
    if config/msg-order = 'new-first [msgs: head reverse msgs]
    emit-messages msgs
    emit [
        <p><b>
        href config/cgi-path "Return to Topics" </a> " | "
        link-topic/bookmark topic-id "end" "Refresh" </a>
        </b><p>
    ]
    emit {<h2 id=end>Add a Message:</h2>}
    emit-form topic-id
    reform ["Messages for:" rec/1]
    ] ; (TGD) ;
]

;-- CGI Command Processing ---------------------------------------------------

; Read CGI request and convert it to a standard object:
; (TGD) ;if not cgi: read-cgi [quit]
; (TGD) ;cgi: construct/with decode-cgi cgi context [
; (TGD) ;    cmd: id: name: email: subject: message: none
; (TGD) ;]
if cgi: read-cgi [
cgi: make context [
    cmd: id: name: email: subject: message: none
] decode-cgi cgi

; Filter out restricted HTML tags from being submitted to any field.
foreach word next first cgi [
    val: get in cgi word
    if string? val [set in cgi word filter-tags val]
]

; Convert CGI fields as needed:
cgi/cmd: attempt [to-word cgi/cmd]
cgi/id: attempt [to-integer cgi/id]
if not email? cgi/email: attempt [load cgi/email] [cgi/email: none]

check-fields: func [/subject][
    if all [not abort subject empty? trim cgi/subject] [show-error "Subject required"] ; (TGD) ;
    if all [not abort empty? trim cgi/name] [show-error "Name field required"]         ; (TGD) ;
    if all [not abort empty? trim cgi/message] [show-error "Message is required"]      ; (TGD) ;
    not abort                                                                          ; (TGD) ;
]

; Process the CGI command:
switch/default cgi/cmd [
    msgs [
        title: list-messages cgi/id
    ]
    msg [
        if all [check-fields rec: must-find-topic cgi/id] [ ; (TGD) ;
; (TGD) ;           rec: must-find-topic cgi/id
           add-message cgi/id cgi/name cgi/email cgi/message
           title: list-messages/update cgi/id
        ] ; (TGD) ;
    ]
    topic [
        if check-fields/subject [ ; (TGD) ;
           id: add-topic cgi/subject
           add-message id cgi/name cgi/email cgi/message
           title: list-messages/update id
        ] ; (TGD) ;
        
    ]
    source [
        title: "REBOL Message Board Source"
        emit [
            <h2> "REBOL Code" </h2>
            <pre> detab encode-html read %rbbs.r </pre>
            <h2> "HTML Form Code (form.html)" </h2>
            <pre> detab encode-html read config/html-form </pre>
            <h2> "HTML Template Code (template.html)" </h2>
            <pre> detab encode-html read config/html-template </pre>
        ]
    ]
][
    title: config/title
    emit-topics
    emit {<h2>Add a New Topic:</h2>}
    emit-form none
]

if not abort [show-page title html]
] ; (TGD) ;
; halt ; (TGD) ;