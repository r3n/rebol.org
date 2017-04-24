REBOL [
    Title: "Web Site Builder"
    Date: 3-Jun-1999
    File: %build-site.r
    Author: "Carl Sassenrath"
    Purpose: {The actual script that builds the REBOL web site (using a master template and a navigation structure).}
    library: [
        level: 'advanced 
        platform: 'all 
        type: 'Tool 
        domain: [file-handling html markup web] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

Verbose: on          ; print more info
Auto-expand: off     ; auto expanding menus

Source-Dir: %source  ; where to find raw page content files
Output-Dir: %www     ; where to put the finished HTLM files

site-path: "www.rebol.com/www"


;****** REBOL Site Structure **************************************************
;   Specifies the structure of the web site, and is used to build the
;   navigation menu on the left side of the screen.

Menu: [

    HOME %home.html none

    INTRODUCTION %introduction.html [
        "In a Nutshell"       %nutshell.html
        "REBOL Features"      %features.html
        "REBOL with a Cause"  %rebolcause.html
        "Messaging Language?" %msglang.html
        "REBOL in Ten Steps"  %rebolsteps.html
    ]
                                           
    DOWNLOAD %downloads.html none

    LIBRARY %library.html [
       "Script Library"     %examples.html
       "User's Library"     %userlib.html
   ]

    SUPPORT %support.html [
        "How-To"            %howto.html
        "Guides"            %docs.html
        "Feedback"          %feedback.html
    ]

    COMPANY %company.html [
        "Mission & Vision"  %mission.html
        "Fact Sheet"        %factsheet.html
        ;"In the News"       %inthenews.html
        "Backgrounder"      %background.html
        "Executive Bios"    %bios.html
        "To Contact Us"          %contacts.html
    ]

    JOBS %jobs.html none
]

Other-files: [
    %application.html
    %jobthanks.html
    %missing.html
    %news9511.html
    %platforms.html
    %releases.html

    ;-- How-tos:
    %database.html %ftp.html %email-read.html
    %email-send.html %net-setup.html %series-format.html
    %tcp.html %web-read.html
]


;****** Utility Functions *****************************************************

error: func [msg] [print msg halt]


;****** HTML Template *********************************************************
;   Specifies the HTML template markers.  These are words which will hold
;   the location of the insertion points for various items in the template.
;   The loop searchs for each word, then sets the word to the location.

Markers: [menu-area content-area]  ; must be unique words in the template

Template: read source-dir/master.html

item: template
foreach word markers [
    item: find item form word
    if none? item [error ["No template marker for:" word]]
    set word index? item
    remove/part item length? form word
]

Updated-files: []

time-stamp: either exists? %timestamp.r [load %timestamp.r][1-1-1900]


;****** Builder Functions *****************************************************

make-page: func [
    "Make the new web page with menus."
    file section title
    /local contents page
][
    if not exists? source-dir/:file [error ["Missing source file:" file]]
    if all [time-stamp > modified? %build-site.r
        time-stamp > modified? source-dir/:file] [exit]
    if verbose [print ["Building:" file]]
    contents: read source-dir/:file
    if not parse contents [to "<body" thru ">" copy page to </body> to end][
        error ["Invalid source file:" file]
    ]

    ; Insert the body html into the template at the desired position:
    page: head insert at copy template content-area page
    make-menu page section title
    insert find page </title> join " " title
    write output-dir/:file page
    append updated-files file
]

make-menu: func [
    "Make the approriate menu for a page."
    page section title
    /local menu-part
][
    menu-part: at page menu-area
    foreach [menu-item file sub-menu] menu [
        menu-part: link-menu menu-part file menu-item false 
            all [menu-item = section title = section]
        if any [not auto-expand menu-item = section] [  ; we are in this section
            if sub-menu <> 'none [
                foreach [titl file] sub-menu [
                    menu-part: link-menu menu-part file titl true titl = title
                ]
            ]
        ]
        menu-part: insert menu-part <P>
    ]
]

link-menu: func [
    "Create a linked menu item."
    menu-tail file text sub current
][
    insert menu-tail reduce either current [[
        either sub [{&nbsp;&nbsp;<font size="1" color="#A00000">}][
            {<font color="#A00000"><B>}]
        text<BR>
        either sub [</font>]["</font></B>"]
    ]][[
        either sub [{&nbsp;&nbsp;<font size="1">}][<B>]
        {<A HREF="} form file {">} text </A><BR>
        either sub [</font>][</B>]
    ]]

]


;****** Main Loop *************************************************************

foreach [section file sub-menu] menu [
    make-page file section section
    if block? sub-menu [
        foreach [title file] sub-menu [make-page file section title]
    ]
]

foreach file other-files [
    make-page file none none
]

;****** Upload Files **********************************************************

if find/match ask "Upload now? " "y" [
    print "Uploading..."
    either exists? %userpass.r [do %userpass.r][
        user: ask "Username? "
        pass: ask "Password? "
    ]
    foreach file updated-files [
        print ["Uploading:" file]
        ;write join ftp:// [user ":" pass "@" site-path "/" file] read output-dir/:file
    ]
    ;save %timestamp.r now
]

quit