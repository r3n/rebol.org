REBOL [
    title: "Web Server Management Tool"
    date: 3-oct-2009
    file: %web-tool.cgi

    purpose: {

        A CGI script to manage your web server.  List directory contents, 
        upload, download, edit, and search for files, execute OS commands
        (chmod, ls, mv, cp, etc. - any command available on your web server's
        operating system), and run REBOL commands directly on your server.
        Edited files are automatically backed up into an "edit_history" folder
        on the server before being saved.  No configuration is required for
        most web servers.  Just put this script AND the REBOL interpreter
        into the same folder as your index.html file, set permissions (chmod)
        to 755, then go to http://yourwebsite/web-tool.cgi  :)

        ** THIS SCRIPT CAN POSE A MAJOR SECURITY THREAT TO YOUR SERVER  **

        It can potentially enable anyone to gain control of your web server
        and everything it contains.  DO NOT install it on your server if you're
        at all concerned about security, or if you don't know how to secure your
        server yourself.

        The first line of this script must point to the location of the REBOL
        interpreter on your web server, and you must use a version of REBOL
        which supports the "call" function (version 2.76 is recommended).  By
        default, the REBOL interpreter should be uploaded to the same path
        as this script, that folder should be publicly accessible, and you must
        use the correct version of REBOL for the operating system on which
        your server runs.  IN THIS EXAMPLE, THE REBOL INTERPRETER HAS
        BEEN RENAMED "REBOL276".

        Taken from the tutorial at http://musiclessonz.com/rebol.html

    }
] 

;-------------------------------------------------------------------

; THE SCRIPT BEGINS ON THE LINE BELOW.  If you install it on your web
; server, erase everything before "#! ./rebol276 -cs".

;-------------------------------------------------------------------

#! ./rebol276 -cs
REBOL [Title: "REBOL CGI Web Site Manager"]

;-------------------------------------------------------------------------

; Upload this script to the same path as index.html on your server, then
; upload REBOL interpreter to the path above (same, by default), chmod it
; AND this script 755.  Run this script at www.yoursite.com/web-tool.cgi .

;-------------------------------------------------------------------------

; YOU CAN EDIT THESE VARIABLES, _IF_ NECESSARY (change the quoted values):

; The user name you want to use to log in:

    set-username:   "username"

; The password you want to use to log in:

    set-password:   "password"

;-------------------------------------------------------------------------

; Do NOT edit these variables:

doc-path: to-string what-dir
script-subfolder: find/match what-dir doc-path
if script-subfolder = none [script-subfolder: ""]

;-------------------------------------------------------------------------

; Get submitted data:
 
selection: decode-cgi system/options/cgi/query-string

read-cgi: func [/local data buffer][
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
    the-data: data
    data
]
submitted: read-cgi
submitted-block: decode-cgi the-data

; ------------------------------------------------------------------------

; This section should be first because it prints a different header
; for a push download (not "content-type: text/html^/"):

if selection/2 = "download-confirm" [
    print rejoin [
        "Content-Type: application/x-unknown"
        newline
        "Content-Length: "
        (size? to-file selection/4) 
        newline
        "Content-Disposition: attachment; filename=" 
        (second split-path to-file selection/4)
        newline
    ]

    data: read/binary to-file selection/4
    data-length: size? to-file selection/4
    write-io system/ports/output data data-length
    quit
]

;-------------------------------------------------------------------------

; Print the normal HTML headers, for use by the rest of the script:

print "content-type: text/html^/"
print {<HTML><HEAD><TITLE>Web Site Manager</TITLE></HEAD><BODY>}

;-------------------------------------------------------------------------

; If search has been called (via link on main form):

if selection/2 = "confirm-search" [
    print rejoin [
        {<center><a href="./} 
        (second split-path system/options/script) {?name=} set-username
        {&pass=} set-password {">Back to Web Site Manager</a></center>}
    ]
    print {<center><table border="1" cellpadding="10" width=80%><tr><td>}
    print [<CENTER><TABLE><TR><TD>]
    print rejoin [
        {<FORM ACTION="./} (second split-path system/options/script) 
        {"> Text to search for: <BR> <INPUT TYPE="TEXT" SIZE="50"}
        {NAME="phrase"><BR><BR>Folder to search in: <BR>}
        {<INPUT TYPE="TEXT" SIZE="50" NAME="folder" VALUE="} what-dir
        {" ><BR><BR><INPUT TYPE=hidden NAME=perform-search }
        {VALUE="perform-search"><INPUT TYPE="SUBMIT" NAME="Submit" }
        {VALUE="Submit"></FORM></TD></TR></TABLE></CENTER>}
        {</td></tr></table></center></BODY></HTML>}
    ]
    quit
]

;-------------------------------------------------------------------------

; If edited file text has been submitted:

if submitted-block/2 = "save" [

    ; Save newly edited document:
    write (to-file submitted-block/6) submitted-block/4
    print {<center><strong>Document Saved:</strong>
        <br><br><table border="1" width=80% cellpadding="10"><tr><td>}
    prin [<center><textarea cols="100" rows="15" name="contents">]
    prin replace/all read (
        to-file (replace/all submitted-block/6 "%2F" "/")
    ) "</textarea>" "<\/textarea>"
    print [</textarea></center>]
    print rejoin [
        {</td></tr></table><br><a href="./} 
        (second split-path system/options/script) {?name=} set-username
        {&pass=} set-password {">Back to Web Site Manager</a></center>}
        {</BODY></HTML>}
    ]
    quit
]

;-------------------------------------------------------------------------

; If upload link has been clicked, print file upload form:

if selection/2 = "upload-confirm" [
    print rejoin [
        {<center><a href="./} 
        (second split-path system/options/script) {?name=} set-username
        {&pass=} set-password {">Back to Web Site Manager</a></center>}
    ]
    print {<center><table border="1" cellpadding="10" width=80%><tr><td>}
    print {<center>}

    ; If just the link was clicked - no data submitted yet:
  
    if selection/4 = none [
        print rejoin [
            {<FORM ACTION="./} (second split-path system/options/script)
            {" METHOD="post" ENCTYPE="multipart/form-data">
                <strong>Upload File:</strong><br><br> 
                <INPUT TYPE=hidden NAME=upload-confirm 
                VALUE="upload-confirm">
                <INPUT TYPE="file" NAME="photo"> <br><br>
                Folder: <INPUT TYPE="text" NAME="path" SIZE="35" 
                    VALUE="} what-dir {"> 
                <INPUT TYPE="submit" NAME="Submit" VALUE="Upload">  
            </FORM>
            <br></center></td></tr></table></center></BODY></HTML>}
        ]
        quit
    ]
]

;-------------------------------------------------------------------------

; If upload data has been submitted:

if (submitted/2 = #"-") and (submitted/4 = #"-") [

    ; This function is by Andreas Bolka:

    decode-multipart-form-data: func [
        p-content-type
        p-post-data
        /local list ct bd delim-beg delim-end non-cr
        non-lf non-crlf mime-part
    ] [
        list: copy []
        if not found? find p-content-type "multipart/form-data" [
            return list
        ]
        ct: copy p-content-type
        bd: join "--" copy find/tail ct "boundary="
        delim-beg: join bd crlf
        delim-end: join crlf bd
        non-cr:     complement charset reduce [ cr ]
        non-lf:     complement charset reduce [ newline ]
        non-crlf:   [ non-cr | cr non-lf ]
        mime-part:  [
            ( ct-dispo: content: none ct-type: "text/plain" )
            delim-beg ; mime-part start delimiter
            "content-disposition: " copy ct-dispo any non-crlf crlf
            opt [ "content-type: " copy ct-type any non-crlf crlf ]
            crlf ; content delimiter
            copy content
            to delim-end crlf ; mime-part end delimiter
            ( handle-mime-part ct-dispo ct-type content )
        ]
        handle-mime-part: func [
            p-ct-dispo
            p-ct-type
            p-content
            /local tmp name value val-p
        ] [
            p-ct-dispo: parse p-ct-dispo {;="}
            name: to-set-word (select p-ct-dispo "name")
            either (none? tmp: select p-ct-dispo "filename")
                   and (found? find p-ct-type "text/plain") [
                value: content
            ] [
                value: make object! [
                    filename: copy tmp
                    type: copy p-ct-type
                    content: either none? p-content [none][copy p-content]
                ]
            ]
            either val-p: find list name
                [
                    change/only next val-p compose [
                        (first next val-p) (value)
                    ]
                ]
                [append list compose [(to-set-word name) (value)]]
        ]
        use [ct-dispo ct-type content] [
            parse/all p-post-data [some mime-part "--" crlf]
        ]
        list
    ]

    ; After the following line, "probe cgi-object" will display all parts
    ; of the submitted multipart object:

    cgi-object: construct decode-multipart-form-data 
        system/options/cgi/content-type copy submitted

    ; Write file to server using the original filename, and notify the
    ; user:

    the-file: last split-path to-file copy cgi-object/photo/filename
    write/binary 
        to-file join cgi-object/path the-file 
        cgi-object/photo/content
    print rejoin [
        {<center><a href="./} 
        (second split-path system/options/script) {?name=} set-username
        {&pass=} set-password {">Back to Web Site Manager</a></center>}
    ]
    print {
        <center><table border="1" width=80% cellpadding="10"><tr><td>
        <strong>UPLOAD COMPLETE</strong><br><br></center>
        <strong>Files currently in this folder:</strong><br><br>
    }
    change-dir to-file cgi-object/path
    folder: sort read what-dir
    foreach file folder [
        print [
            rejoin [
                {<a href="./} (second split-path system/options/script)
                {?editor-confirm=editor-confirm&thefile=} 
                what-dir file {">(edit)</a>   }
                {<a href="./} (second split-path system/options/script)
                {?download-confirm=download-confirm&thefile=}
                what-dir file {">} "(download)</a>   " 
                {<a href="./} (find/match what-dir doc-path) file 
                {">} file {</a><br>}
            ]
        ]
    ]
    print {</td></tr></table></center></BODY></HTML>}
    quit
]

;-------------------------------------------------------------------------

; If no data has been submitted, print form to request user/pass:

if ((selection/2 = none) or (selection/4 = none)) [
    print rejoin [{
        <STRONG>W A R N I N G  -  Private Server, Login Required:</STRONG>
        <BR><BR>
        <FORM ACTION="./} (second split-path system/options/script) {">
        Username: <INPUT TYPE=text SIZE="50" NAME="name"><BR><BR>
        Password: <INPUT TYPE=text SIZE="50" NAME="pass"><BR><BR>
        <INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">
        </FORM></BODY></HTML>
    }]
    quit
]

;-------------------------------------------------------------------------

; If a folder name has been submitted, print file list:

if ((selection/2 = "command-submitted") and (
    selection/4 = "call {^/^/^/^/}")
) [
    print rejoin [
        {<center><a href="./} 
        (second split-path system/options/script) {?name=} set-username
        {&pass=} set-password {">Back to Web Site Manager</a></center>}
    ]
    print {<center><table border="1" cellpadding="10" width=80%><tr><td>}
    print {<strong>Files currently in this folder:</strong><br><br>}
    change-dir to-file selection/6
    folder: sort read what-dir
    foreach file folder [
        print rejoin [
            {<a href="./} (second split-path system/options/script)
            {?editor-confirm=editor-confirm&thefile=}
            what-dir file {">} "(edit)</a>   " 
            {<a href="./} (second split-path system/options/script)
            {?download-confirm=download-confirm&thefile=}
            what-dir file {">} "(download)</a>   " 
            {<a href="./} (find/match what-dir doc-path) file {">} file
            {</a><br>}
        ]
    ]
    print {</td></tr></table></center></BODY></HTML>}
    quit
]

;-------------------------------------------------------------------------

; If editor has been called (via a constructed link):

if selection/2 = "editor-confirm" [
    
    ; backup (before changes are made):
    
    cur-time: to-string replace/all to-string now/time ":" "-"
    document_text: read to-file selection/4
    if not exists? to-file rejoin [
        doc-path script-subfolder "edit_history/"
    ] [
        make-dir to-file rejoin [
            doc-path script-subfolder "edit_history/"
        ]
    ]
    write to-file rejoin [
        doc-path script-subfolder "edit_history/" 
        to-string (second split-path to-file selection/4)
        "--" now/date "_" cur-time ".txt"
    ] document_text
    
    ; note the POST method in the HTML form:
    
    print rejoin [
        {<center><strong>Be sure to SUBMIT when done:</strong>}
        {<BR><BR><FORM method="post" ACTION="./} 
        (second split-path system/options/script) {">}
        {<INPUT TYPE=hidden NAME=submit_confirm VALUE="save">}
        {<textarea cols="100" rows="15" name="contents">}
        (replace/all document_text "</textarea>" "<\/textarea>")
        {</textarea><BR><BR><INPUT TYPE=hidden NAME=path VALUE="}
        selection/4
        {"><INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">
        </FORM></center></BODY></HTML>}
    ]
    quit
]

;-------------------------------------------------------------------------

; If search criteria has been entered:

if selection/6 = "perform-search" [
    phrase: selection/2
    start-folder: to-file selection/4
    change-dir start-folder
    ; found-list: ""

    recurse: func [current-folder] [ 
        foreach item (read current-folder) [ 
            if not dir? item [  
                if error? try [
                    if find (read to-file item) phrase [
                        print rejoin [
                            {<a href="./}
                            (second split-path system/options/script)
                            {?editor-confirm=editor-confirm&theitem=} 
                            what-dir item {">(edit)</a>   }
                            {<a href="./}
                            (second split-path system/options/script)
                            {?download-confirm=download-confirm&theitem=}
                            what-dir item {">(download)</a>   "}
                            phrase {" found in:  } 
                            {<a href="./} (find/match what-dir doc-path)
                            item {">} item {</a><BR>}
                        ]
                        ; found-list: rejoin [
                        ;     found-list newline what-dir item
                        ; ]
                    ] 
                ] [print rejoin ["error reading " item]]
            ]
        ]
        foreach item (read current-folder) [ 
            if dir? item [
                change-dir item 
                recurse %.\
                change-dir %..\
            ] 
        ]
    ]

    print rejoin [
        {<center><a href="./} 
        (second split-path system/options/script) {?name=} set-username
        {&pass=} set-password {">Back to Web Site Manager</a></center>}
    ]
    print {<center><table border="1" cellpadding="10" width=80%><tr><td>}
    print rejoin [
        {<strong>SEARCHING for "} phrase {" in } start-folder
        {</strong><BR><BR>}
    ]
    recurse %.\
    print {<BR><strong>DONE</strong><BR>}
    print {</td></tr></table></center></BODY></HTML>}
    ; save %found.txt found-list
    quit
]

;-------------------------------------------------------------------------

; This is the main entry form, used below:

entry-form: [
    print rejoin [
        {<CENTER><strong>current path: </strong>} what-dir 
        {<FORM METHOD="get" ACTION="./} 
        (second split-path system/options/script) {">}{<INPUT TYPE=hidden}
        { NAME=submit_confirm VALUE="command-submitted">}
        {<TEXTAREA COLS="100" ROWS="10" NAME="contents">}
        {call {^/^/^/^/}</textarea><BR><BR>}
        {List Files: <INPUT TYPE=text SIZE="35" NAME="name" VALUE="} 
        what-dir {"><INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">}
        {          <A HREF="./} (second split-path system/options/script)
        {?upload-confirm=upload-confirm">upload</A>       } ; leave spaces
        {<A HREF="./} (second split-path system/options/script)
        {?confirm-search=confirm-search">search</A>} 
        {</FORM><BR></CENTER>}
    ]
]

;-------------------------------------------------------------------------

; If code has been submitted, print the output, along with an entry form):

if ((selection/2 = "command-submitted") and (
selection/4 <> "call {^/^/^/^/}") and ((to-file selection/6) = what-dir))[
    write %commands.txt join "REBOL[]^/" selection/4
    ; The "call" function requires REBOL version 2.76:
    call/output/error 
        "./rebol276 -qs commands.txt" 
        %conso.txt %conse.txt
    do entry-form
    print rejoin [
        {<CENTER>Output: <BR><BR>}
        {<TABLE WIDTH=80% BORDER="1" CELLPADDING="10"><TR><TD><PRE>}
        read %conso.txt
        {</PRE></TD></TR></TABLE><BR><BR>}
        {Errors: <BR><BR>}
        read %conse.txt
        {</CENTER></BODY></HTML>}
    ]
    quit
]
;-------------------------------------------------------------------------

if ((selection/2 = "command-submitted") and (
    selection/4 <> "call {^/^/^/^/}") and (
    (to-file selection/6) <> what-dir)
) [
    print rejoin [
        {<center><a href="./} 
        (second split-path system/options/script) {?name=} set-username
        {&pass=} set-password {">Back to Web Site Manager</a></center>}
    ]
    print {
        <center><table border="1" cellpadding="10" width=80%><tr><td>
            <center>
        You must EITHER enter a command, OR enter a file path to list.<BR>
        Please go back and try again (refresh the page if needed).
            </center>
        </td></tr></center></BODY></HTML>
    }
    quit
]

;-------------------------------------------------------------------------

; Otherwise, check submitted user/pass, then print form for code entry:

username: selection/2 password: selection/4 
either (username = set-username) and (password = set-password) [ 
    ; if user/pass is ok, go on
][
    print "Incorrect Username/Password. </BODY></HTML>" quit
]

do entry-form
print {</BODY></HTML>}
