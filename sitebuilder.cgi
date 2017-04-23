Rebol [
    title: "CMS - web site builder"
    date: 20-Nov-2009
    file: %sitebuilder.cgi
    author:  Nick Antonaccio
    purpose: {
    Easily create, edit, and arrange HTML pages on your web site.  Upload existing
    content files or use the built-in WSYIWYG HTML editor (from openwebware.com)
    to layout pages visually, without having to write any code.  It works just like a
    word processor, except it runs directly in your browser, right on your web site.
    You can adjust fonts, colors, and other essential formatting/layout options.  You
    can add tables, images, links, and other elements, all without writing any code.
    Of course, if you prefer to write your own HTML code or copy/paste from other
    sources, you can switch instantly between visual and code view, for complete
    control and instant preview.  The built-in file upload allows you to transfer any
    HTML files, scripts, images, or binary files of any sort to your web site, from any
    computer.  The template system automatically builds menu links to other pages
    on your site using a simple and quick site map layout that you specify, and the
    generated pages are all wrapped in templates that you can upload or create/edit
    directly online (2 generic templates are included to get you started).  Because 
    the whole system runs in your browser, you can add pages, upload files, and
    edit site content instantly from any location, using any OS, without installing any
    software.  Setup takes just a few seconds:  simply upload this script and an 
    appropriate REBOL interpreter to the public_html folder of your web site, set
    permissions and the shebang line of this script, then start adding/editing pages.
    Absolute beginners can learn how to use it in a few minutes.

    THIS SCRIPT CAN BE A POTENTIALLY MAJOR SECURITY RISK TO YOUR WEB SITE.  IT
    CAN GIVE ANYONE COMPLETE CONTROL OF ALL FILES ON YOUR SERVER. DO NOT PUT
    IT INTO A PUBLICLY ACCESSIBLE FOLDER OF YOUR WEB SERVER UNLESS YOU ARE
    ABSOLUTELY SURE THAT YOU UNDERSTAND AND ARE WILLING TO ACCEPT/MANAGE
    THE RISKS OF UPLOADING THIS SCRIPT.

    A working version of this script is available for the Cheyenne web server at:

    http://re-bol.com/cheyenne 

    }
]

; THE SCRIPT STARTS ON THE LINE BELOW.  BEFORE UPLOADING TO YOUR WEB SITE,
; ERASE EVERYTHING PRECEDING IT.   The first character on the first line of your script 
; must be the "#" below:

#!./rebol276 -cs
REBOL []
print "content-type: text/html^/"
print [<HTML><HEAD><TITLE>"Sitebuilder"</TITLE></HEAD><BODY>]
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
    data
]

submitted: decode-cgi submitted-bin: read-cgi

; if no data has been submitted, request user/pass:

if ((submitted/2 = none) or (submitted/4 = none)) [
    print [<strong>"W A R N I N G  -  "]
    print ["Private Server, Login Required:"</strong><BR><BR>]
    print [<FORM METHOD="post" ACTION="./sitebuilder.cgi">]
    print [" Username: " <input type=text size="50" name="name"><BR><BR>]
    print [" Password: " <input type=text size="50" name="pass"><BR><BR>]
    print [<INPUT TYPE="SUBMIT" NAME="Submit" VALUE="submit">]
    print [</FORM>]
    print {</BODY></HTML>} quit
]

; check user/pass every time - end program if incorrect:


username: "username"  password: "password"
    
myusername: submitted/2  mypassword: submitted/4
either ((username = myusername) and (password = mypassword)) or ((find submitted/2 {Content-Disposition: form-data;}) <> none) [
     ; if user/pass is ok, go on
][
     print "Incorrect Username/Password."
     print {</BODY></HTML>} quit
] 

if not exists? %sitemap.r [
    write %sitemap.r {%Home []} 
    write %Home {}
]

if not exists? %upload.cgi [
    write/binary/allow %upload.cgi to-binary decompress 64#{
eJyFV21v2zYQ/m7A/+GqoYUDTFHaAV2h2A7aNVsHpEixZhgGwxsoibbZSqJKUs2M
LP99d3yRZNnFBFgv5N3xubvnjvR3T84TxTNZvvjxJcS5nk5+u35zewOr9XTSKFEb
eMhlbXhtYrNveAqG/2OSnanKv5LHILKav7t7f7Ocv7t+/XY5v/v17uZ6GX0Uhmet
KAuuonniBueJE3lz+/bPJa4wnSjOijjfihQ2bZ3DKillzkoomGGQtZsNV+vVdAJ4
6Xth8h3ovTa8SmRjhKx1gqqI/0vLtYkrbnayAC9PV/Th9uNdNByhi4ynULHPHLRB
B7ZP4PnFi4tDIbf4WOzlD69Gcvc7UXJYNVILI77yK7AeCRmANlIZnYi6aY236ays
R6DoYk3D62Lo/LFMXnKmTs6u+8/Ba/TLNUXA+XwieBg6tY+dg17NP0hlOrFZKngu
Cx5XbWlEw5SJN1JVsbPp8uZUmnhIljCGsTGxs0YDPsWl0AZyDAo6zEtRxRnf+jcK
Qi3rOFf2UW78F75UouIxQUBkYVWylEIum72lLQ0JUjGwkW1dXMFGoMFDbBB1ziSd
MxgnTJ9pVe3QWd9t0IP9Uw5mRQqfpKghiuPIidGCiWGiJAejjFAwtV9EPrDBXa+H
ESDfhpMYAT9pvc6KgMQFInVUkFVT8grRQL5jSnOD6Is2RzqiWkiji+D/a9T8vhQ1
H6rR2qS4Ctn4F/qUeLkuISg4oPQMPY8LoRtJkbMhS0mT07jrJJFtJU3JRB3BWa/a
s+Gyt44lSHc7h41lQP0oZMSuRlUoazTuEhFAAKv3PYn6aNOF1YAeRodtrte3bDlS
H5aY/b4Mbp7C6Gy5+X7UyAHfvZHeYdsJjk3NYMfqosRi7CQ7JwPagOSsq2f3MtY8
LF5fwN7YaKyn+0Gd90O+qk3VQM0qDl9Z2dp73HgUp9dJoSEiDkbg4XIRPQbMloto
EHceGSNh43upCphpXnKsrYFWRFLRgEdcmB122xmx7oqAYf871tpg+x5r+gujBbNR
CwndY8Dds/H+Yl1Pj/O9/oag3WJk9gmhPRmL0BUg+h6EnhzLONaGHjXOV7i6SvSx
caHpsukKnRPQUbsb0t26crDXHMXcpj11QbOdlOAfWlhRB6q3PJF1ibWF4XRatkdJ
TR1pthGKdLu5M5jZkJ0hwvXYnN883bbS2xiyhlCcsNF50FqVb5bTIYOJtQkry+EG
h9paIvn72nR7wqBhdIsRUL+9dvophPPQdIK32JHCUgl36Dan5vKtnfjU5n6w47mM
9nvxdHIJjZIZznRLYQci30u212B9wyU0yA1gWkG3GTYjwwvolve0JVN/KGxUlqvU
2DRXX5EIrcZjhVWWSmxFjR0isPl7W1+4S4vN3kpg9FVKsPAjJqkUSobJRDjCYDTN
jlqAXcD10w510uykkUmwPJ3cE5Ykw/WUte21xgpdhfqT7jzHL66WcwY7xTeL6DzR
/Sn2HPWvyP6CkNLLs4ZpvaAb0euZi8/CPaLlG5Z/plAMDsLzhC3nmVo+9ksaliG0
e1GY3eLVxVPI0BJXi+cHMgjJFF7o+cXFU2skoO0FHbHmSBVZb5e/f7i5ff0Wfrp9
/+Hm+u56nvhxq4u/Q+mfMUIa8lYptIoViUcPsxMaj1AEPD2hjev6SSS9Mpa68PSc
RvEVj+o26E6kOyC6/wuK27PN6mEQ6Ucn/xAB7vRbbhZ/ZyWrPy/9eBRiF63XtmxC
cAhPYgq62TeKJz7tXwz8v0F/TBDpl1aY/wDPpuhm7AwAAA==
} [read write execute read write execute read write execute]
    if error? try [call {chmod 755 ./upload.cgi}] [
        print rejoin [{
            <center><table border="1" width=80% cellpadding="10"><tr><td>
            <strong>./upload.cgi</strong> has been created, but there was apparently a problem
            setting permissions for it.  Please be sure that upload.cgi is chmod to 755.<br><br>
            <center><a href="./sitebuilder.cgi?name=} username {&pass=} password {&submit=submit">Continue</a>
            </center></td></tr></table></center></BODY></HTML>
        }] quit
    ]
]

; if only user/pass has been entered, print main start page :

if submitted/6 = "submit" [
    ; write/append %sitemap.r ""  ; make sure it exists
    print rejoin [
        "<center>Path: " what-dir 
        {<br><table border="1" width=80% cellpadding="10"><tr><td>}
    ]
    print rejoin [
        {<br>
        <FORM ACTION="./upload.cgi" METHOD="post" ENCTYPE="multipart/form-data">
        Upload File: <INPUT TYPE="file" size="50" NAME="photo">
        <INPUT TYPE="submit" NAME="Submit" VALUE="Upload">
 &nbsp;  &nbsp;  &nbsp;   <a href="./sitebuilder.cgi?name=} username {&pass=} password {&subroutine=listfiles">Files</a>  
        </FORM>
        <FORM method="post" ACTION="./sitebuilder.cgi"> 
        <INPUT TYPE=hidden NAME=username VALUE="} submitted/2 {">
        <INPUT TYPE=hidden NAME=password VALUE="} submitted/4 {">
        <INPUT TYPE=hidden NAME=subroutine VALUE="edit">
        Create New Page: 
        <INPUT TYPE=text size="50" name="file" value="">
        <INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">
        </FORM>}
    ]
    pages: sort read %.
    dont-show-suffixs: [%.html %.jpg %.gif %.png %.bmp %.rip %.exe %.pdf %.cgi %.php %.zip %.txt %.tpl %.r %.tgz]
    remove-each page pages [find dont-show-suffixs (suffix? page)]
    remove-each page pages [find to-string page "/"]  ; don't show directories
    dont-show-files: [%rebol276 %sitemap %.ftpquota]  ; and a few other odd files 
    remove-each page pages [find dont-show-files page]
    print "<hr><br>Edit Existing Pages:<br><br>"
    foreach page pages [
        print rejoin [
            {<a href="./sitebuilder.cgi?name=} username {&pass=} password {&subroutine=edit&file=}
            to-string page {">} to-string page {</a> &nbsp; &nbsp;
            } ; <br>}
        ]
    ]
    print {<br><br><hr>}
    print rejoin [{<a href="./sitebuilder.cgi?name=} username {&pass=} password {&subroutine=cleanedit&file=sitemap.r">Edit Site Map</a> &nbsp;  &nbsp;  &nbsp;  }]
    print rejoin [{<a href="./sitebuilder.cgi?name=} username {&pass=} password {&subroutine=buildsite">Build Site</a> &nbsp;  &nbsp;  &nbsp;  }]
    print rejoin [{<a href="./} (to-string first load %sitemap.r) {.html" target=_blank>View Home Page</a> &nbsp;  &nbsp;  &nbsp;  }]
    print rejoin [{<a href="./sitebuilder.cgi?name=} username {&pass=} password {&subroutine=console">Console</a> &nbsp;  &nbsp;  &nbsp;  }]
    print rejoin [{<a href="./sitebuilder.cgi?name=} username {&pass=} password {&subroutine=instructions">Instructions</a>}]
    print {<br></td></tr></table></center></BODY></HTML>} quit
]

; if constructed edit link has been submitted:

if submitted/6 = "edit" [
    write/append to-file rejoin [what-dir submitted/8] ""  ; create new if it doesn't exist
    if not exists? %./openwysiwyg/scripts/wysiwyg.js [
        write/binary %./openwysiwyg.rip to-binary decompress 64#{
            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
        }
        print {
            <center><table border="1" width=80% cellpadding="10"><tr><td>
            <center><strong>INITIAL SETUP: PLEASE RELOAD THIS PAGE AFTER FILES HAVE BEEN UNPACKED...</strong>
            </center></td></tr></table></center></BODY></HTML>
        }
        do %openwysiwyg.rip
        print {
            <center><table border="1" width=80% cellpadding="10"><tr><td>
            <center><strong>FILES HAVE BEEN UNPACKED: PLEASE RELOAD THIS PAGE NOW</strong>
            </center></td></tr></table></center></BODY></HTML>
        }
    ]
    ; backup (before changes are made):
    cur-time: to-string replace/all to-string now/time ":" "-"
    document_text: read to-file rejoin [what-dir submitted/8]
    make-dir %edit_history
    write to-file rejoin [
        what-dir "edit_history/" 
        to-string (second split-path to-file submitted/8) 
        "--" now/date "_" cur-time ".txt"
    ] document_text

    ; note the POST method in the HTML form:

    prin rejoin [
        {<script type="text/javascript" src="openwysiwyg/scripts/wysiwyg.js"></script>
        <script type="text/javascript">
            var full = new WYSIWYG.Settings();
            full.ImagesDir = "openwysiwyg/images/";
            full.PopupsDir = "openwysiwyg/popups/";
            full.CSSFile = "openwysiwyg/styles/wysiwyg.css";
            full.Width = "85%"; 
            full.Height = "250px";
            WYSIWYG.attach('all', full);
        </script>}
        {<center><strong>Be sure to SUBMIT when done:</strong><BR><BR>
        <FORM method="post" ACTION="./sitebuilder.cgi"> 
        <INPUT TYPE=hidden NAME=username VALUE="} submitted/2 {">
        <INPUT TYPE=hidden NAME=password VALUE="} submitted/4 {">
        <INPUT TYPE=hidden NAME=subroutine VALUE="save">
        <INPUT TYPE=hidden NAME=path VALUE="} submitted/8 {">
        <textarea id="textarea1" name="test1" cols="100" rows="15" name="contents">}
        replace/all document_text "</textarea>" "<\/textarea>"
        {</textarea>
        <a href="./sitebuilder.cgi?name=} username {&pass=} password {&subroutine=listfiles-popup" target=_blank><FONT size=1>Files</FONT></a><BR><BR>
        <INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">
        </FORM></center></BODY></HTML>}
    ]
    print {</BODY></HTML>} quit
]

; non-wysiwyg edit:

if submitted/6 = "cleanedit" [
    write/append to-file rejoin [what-dir submitted/8] ""  ; create new file if it doesn't exist
    ; backup (before changes are made):
    cur-time: to-string replace/all to-string now/time ":" "-"
    document_text: read to-file rejoin [what-dir submitted/8]
    make-dir %edit_history
    write to-file rejoin [
        what-dir "edit_history/" 
        to-string (second split-path to-file submitted/8) 
        "--" now/date "_" cur-time ".txt"
    ] document_text

    ; note the POST method in the HTML form:

    prin rejoin [
        {<center><strong>Be sure to SUBMIT when done:</strong><BR><BR>
        <FORM method="post" ACTION="./sitebuilder.cgi"> 
        <INPUT TYPE=hidden NAME=username VALUE="} submitted/2 {">
        <INPUT TYPE=hidden NAME=password VALUE="} submitted/4 {">
        <INPUT TYPE=hidden NAME=subroutine VALUE="save">
        <INPUT TYPE=hidden NAME=path VALUE="} submitted/8 {">
        <textarea id="textarea12" name="test2" cols="100" rows="15" name="contents">}
        replace/all document_text "</textarea>" "<\/textarea>"
        {</textarea><br>
        <a href="./sitebuilder.cgi?name=} username {&pass=} password {&subroutine=listfiles-popup" target=_blank><FONT size=1>Files</FONT></a><BR><BR>
        <INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">
        </FORM></center></BODY></HTML>}
    ]
    print {</BODY></HTML>} quit
]

; if edited file text has been submitted:

if submitted/6 = "save" [ 
    ; save newly edited document:
    write (to-file rejoin [what-dir submitted/8]) (replace/all submitted/10 "<\/textarea>" "</textarea>")
    either (submitted/8 <> "sitemap.r") and (submitted/8 <> (to-string first load %sitemap.r)) [
        print {<center><strong>Document Saved</strong><br><br>}
        recurse-sitemap: func [page] [
            append sitemap-pages page/1
            if not (page/2 = []) [foreach block page/2 [recurse-sitemap block]]
        ] 
        sitemap-pages: copy []
        recurse-sitemap load %sitemap.r
        prin {<table border="1" width=80% cellpadding="10"><tr><td><center>Now ADD this page as a SUB-PAGE of another in your site map:<br><br>}
        foreach page sitemap-pages [
            prin rejoin [
                {<a href="./sitebuilder.cgi?name=} username {&pass=} password {&subroutine=addsitemap&newpage=}
                submitted/8 {&existingpage=} page {">} page {</a> &nbsp;  &nbsp;  &nbsp;  }
            ]
        ]
        print rejoin [{
            <br><br>If you've ALREADY added this page to your site map, or if you do not want it in your site map
            <a href="./sitebuilder.cgi?name=} username {&pass=} password {&submit=submit"><strong>click here</strong></a>
            </center><br></td></tr></table></center>
        }]
    ] [
        print rejoin [{<html><head><META HTTP-EQUIV="REFRESH" CONTENT="0; URL=./sitebuilder.cgi?name=} username {&pass=} password {&submit=submit"></head>}]
    ]
    print {</BODY></HTML>} quit
]

; If page has been added to site map via link:


if submitted/6 = "addsitemap" [
    recurse-add-sitemap: func [page] [
        if page/1 = (to-file submitted/10) [
            new-block: copy []
            append new-block (to-file submitted/8)
            append/only new-block []
            insert/only page/2 new-block
        ]
        if not (page/2 = []) [foreach block page/2 [recurse-add-sitemap block]]
    ] 
    recurse-add-sitemap new-site-map: load %sitemap.r
    save %sitemap.r new-site-map
    print rejoin [{<html><head><META HTTP-EQUIV="REFRESH" CONTENT="0; URL=./sitebuilder.cgi?name=} username {&pass=} password {&submit=submit"></head>}]
]

; If file upload has been submitted:

if ((find submitted/2 {Content-Disposition: form-data;}) <> none) [
    decode-multipart-form-data: func [
        p-content-type
        p-post-data
        /local list ct bd delim-beg delim-end non-cr non-lf non-crlf mime-part
    ] [
        list: copy []
        if not found? find p-content-type "multipart/form-data" [return list]
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
                [change/only next val-p compose [(first next val-p) (value)]]
                [append list compose [(to-set-word name) (value)]]
        ]
        use [ct-dispo ct-type content] [
            parse/all p-post-data [some mime-part "--" crlf]
        ]
        list
    ]
    cgi-object: construct decode-multipart-form-data system/options/cgi/content-type copy submitted-bin
    ; probe cgi-object ; displays all parts of the submitted multipart object
    ; Write file to server using the original filename, and notify the user:
    the-file: last split-path to-file copy cgi-object/photo/filename
    write/binary the-file cgi-object/photo/content
    print rejoin [{<center><a href="./sitebuilder.cgi?name=} username {&pass=} password {&submit=submit">Back to Sitebuilder</a><br>}]
    print {<table width=80% border=1>}
    print {<tr><td width=100%><br><center>}
    print {
        <strong>UPLOAD COMPLETE</strong><br><br>
        <strong>Files currently in this folder:</strong><br><br>
    }
    folder: sort read %.
    foreach file folder [
        print [rejoin [{<a href="./} file {" target=_blank>} file "</a><br>"]]
    ]
    print {<br></td></tr></table></BODY></HTML>}
    quit
]

; List existing files:

if submitted/6 = "listfiles" [
    print rejoin [{<center><a href="./sitebuilder.cgi?name=} username {&pass=} password {&submit=submit">Back to Sitebuilder</a><br>}]
    print {<table width=60% border=1 cellpadding="10">}
    print {<tr><td width=100%><br>}
    folder: sort read %.
    foreach file folder [
        print rejoin [{ &nbsp;  &nbsp; <a href="./sitebuilder.cgi?name=} username {&pass=} password {&subroutine=cleanedit&file=} file {">(edit)</a> &nbsp;  &nbsp; }]
        print rejoin [{<a href="./} file {" target=_blank>} file {</a><br>}]
    ]
    print {<br></td></tr></table></center></BODY></HTML>}
    quit
]

if submitted/6 = "listfiles-popup" [
    print {<center><table width=80% border=1>}
    print {<tr><td width=100%><br><center>}
    folder: sort read %.
    foreach file folder [
        print [rejoin [{<a href="./} file {">} file "</a><br>"]]
    ]
    print {<br></center></td></tr></table></center></BODY></HTML>}
    quit
]

; Run REBOL console (for file and OS operations):

if submitted/6 = "console" [
    if not exists? %rebol276 [print "<center>REBOL version 276 required!</center><br>"]
    print rejoin [{<center><a href="./sitebuilder.cgi?name=} username {&pass=} password {&submit=submit">Back to Sitebuilder</a></center>}]
    entry-form: [
        print {
            <CENTER><FORM METHOD="post" ACTION="./sitebuilder.cgi"> 
            <INPUT TYPE=hidden NAME=username VALUE="username">
            <INPUT TYPE=hidden NAME=password VALUE="password">
            <INPUT TYPE=hidden NAME=subroutine VALUE="console">
            <INPUT TYPE=hidden NAME=submit_confirm VALUE="command-submitted">
            <TEXTAREA COLS="100" ROWS="10" NAME="contents"></TEXTAREA><BR><BR>
            <INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">
            </FORM></CENTER></BODY></HTML>
        }
    ]
    if submitted/8 = "command-submitted" [
        write %commands.txt join "REBOL[]^/" submitted/10
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
            {</CENTER>}
        ]
        quit
    ]
    do entry-form
]

; Build site:

if submitted/6 = "buildsite" [
    if not exists? %menu.tpl [
        write %menu.tpl decompress #{
            789CB556DB4EDB40107DE72B0623A456AA63C7691E00AFA5247649A484A46129
            E2A9F265B15D8C9DAE9D00ADFA41FDCBCEAEED90847015355292DD999D3D73E6
            CC1873D71EF7E8C5C4813E1D0D6172D61D0E7AA0A89A76DEEA699A4DEDD2F0B9
            A103E56E9AC7459CA56EA269CE8962ED98C268997DA7635B261DD0A163EDE063
            EEAA2AA02BF3E6711230FEBD888B8481AA5A20CD5AE96A8E1CDA81A828662AFB
            398F17A497A5054B0B95DECD18F8E5822805BB2DB4A8B84E8EC08F5C9EB382DC
            C46990DDE46AD3681B02860CD4A774A23A5FCF06DF88327143A63A18802BD01B
            9F50E7841265CA16CC4D641A1FC09E7357E4428C4FF78991A6F151C43BA51743
            07042FD5F57E9EE3BE7B18650BC6E137824B327E085E326747203CD480F95919
            F110E629269DC429DA3CD7BF0A79863B87B0F7E5C0B11D1BFE2003F206BC4993
            DCED98DDB17D015ED81371C99E2E1FDCA69D2E027193384C89CF443E2B1189A2
            809771BC8BE8E0B32499B84110A72131E4EA74E6FAE52A62711821934D5DDF57
            E0260E8A882807ED7D912A15378BEFA9F8B037C35788121120E4EC0E161D09A6
            C8664B78EF85482EDE00A93A6EB4CAD3DB3055676E2214658DB0B986B0A9BF1C
            220868880C6F9BAC15072D5F506DA53C48374110D807BF1869A1E5944EC727C7
            F8C38588B34BA2A088D96D43285BB1FAD9353335D712CAA8DC34114A7C4F7017
            2FC30F418826132CB79EA0C79397574934756B13A96CC41A49435BC5620E46C7
            95B3E7E64C0819974885D0AA3385C1A873ECAC143ACA9134863F72EE8B581173
            D1D0F8310B3116E654F6FC7A16756D9F97D35A3EFF5B5CD551437F58DAD5CA96
            3A929535ACBAB02396CE97E5ABAAB72D6DC1C6EB1AED0194AE909F24ABCC0E7B
            D9326BE3E6F0C5FA5DE562F89A5AEDB2D45085AE1ECB5321B792A1DA074C8F57
            4E0F51BFB87A7B97F279DFFA9945F02C8BF7055DF273CF4211BCB81ACB38CBF1
            29E0949AA83AFCD102CCDC22DAE0FF125F6E2B00DE21918DBE5A0F87AA457A53
            D25AE7F63513BCD97E6B976D657855DD9B7C556FFE923231E56A716E6AF3BEB3
            1EB73CF71AD90B5AE2AF4EA7BD6DA6D76DF25498F295FD449847E647D3EA65B3
            3B2E4EC15F3074FD006814E770CE3C3845AF06749204A43D07CE72C6172C686C
            1D2F2FA747125A954893FFC3EDFC039C3D1A760A0A0000
        }
    ]
    if not exists? %nomenu.tpl [
        write %nomenu.tpl decompress #{
            789CAD556D6FDA3010FECEAFB8A6AAB4490B09B47C288D235192162468197557
            F5D3E4246E92CD4B9863A0DDB41FB47FB973121874636DA7FA83E397E3B9E79E
            3B1FCE9E77D9A7B7131F06743C82C9F5E968D807C3B4AC9BC3BE6579D4AB2E8E
            9A3650C9B22255699E316159FE85E1361C7DE93A03BFE7B90E1DD291EF420387
            B3679A80B63C98A722E2F2A34A95E0609AF5B555D9369CB14F7B90283533F9D7
            79BA20FD3C533C53267D987108AB0D3114BF5756A2BE88130813260BAEC832CD
            A27C5998AD76A76DAC8006944E4CFFFDF5F00331262CE6A68F00D280FEE505F5
            2F2831A67CC19928037903DE5C321D0D69BFFB1D1A691DBDD57857F476E48356
            A6761F16059EB36E922FB884EF484EE4B20B8198F313D01666C4C3BC42ECC23C
            C3A8459AE15DC0C2CFB1CCF1A40BFB67C7BEE77BF00325283DA027AB54AFE19C
            5E7AB710C47D8D4BF6ED72E031ED9D221126D2382321D7F16C2012C3802097E8
            8BD8107221262C8AD22C26ED7277356361B54B781A27A864CBB60F0C58A6914A
            8871DC39D0A152ED597FA77AF21EC3D78C840688257F8045AF24A3F2D99ADE6B
            312A37DB9476330A041EAF705AB6EB4CB66472CB4A6390487E478CA68505C3EF
            9BBA8A0CD7198ECF6BE380155C270AB7C846E7C29FC270DC3BF73702490AE4CD
            7151C89018096778DCFC348B11C96295236B826BEAE969BA53CCA7A55BE5FFAE
            1CAF2B253C2BBD355A1B05AD8574ACF5424565B42F016AD9EB7AD38CD6A08F5B
            C48CA94477880D6F28E74BBDEDA6FDCFC4E06B463D3372B82DE64B0ABCD5F9CF
            B4FC3DC28D52F943AABA31566AD52295E1E154E2E257D3DEA8C8DD374F3DFCBA
            15ADC2E9A0EDA387E69C617FAD1A225926C813C97EE3A4E5F6F3D983D4BF829F
            D0B6ED63A0495AC00D0FE00AAD9A003D21A0342840F282CB058F9A8EA5E1DCED
            07F5FCC050885A5AABFC736AFC02A1651F4AE3060000
        }
    ]
    homepage: to-string first load %sitemap.r
    current-path: rejoin [
        {<a href="./} homepage {.html">} homepage {</a>}
    ]
    begin-recurse: true
    recurse: func [page current-path][
        either begin-recurse = true [
            print-path: (to-string page/1)
        ] [
            print-path: rejoin [current-path { : } (to-string page/1)]
        ]
        begin-recurse: false
        either (page/2 = []) [
            constructed: replace (read %nomenu.tpl) {<!-- sitebuilder_content -->} (read to-file page/1)
            constructed: replace constructed {<!-- sitebuilder_title -->} (to-string page/1)
            constructed: replace constructed {<!-- sitebuilder_path -->} print-path
        ] [
            constructed: replace (read %menu.tpl){<!-- sitebuilder_content -->}(read to-file page/1)
            link-list: copy {}
            foreach item page/2 [
                link-list: rejoin [
                    link-list
                    {<TR><TD style="border: solid" }
                    {onmouseOver="this.bgColor='#FFFFFF'"; }
                    {onmouseOut="this.bgColor='#D3D3D3'";> }
                    {<CENTER><FONT face="Arial, Verdana, MS Sans Serif" size=1>}
                    {<A HREF="./} (to-string item/1) {.html">} (to-string item/1) {</A>}
                    {</FONT></CENTER></TD></TR>}
                    newline
                ]
            ]
            constructed: replace constructed {<!-- sitebuilder_links -->} link-list
            constructed: replace constructed {<!-- sitebuilder_title -->} (to-string page/1)
            constructed: replace constructed {<!-- sitebuilder_path -->} print-path
        ]
        write (to-file join page/1 ".html") constructed
        print page/1 print { ... DONE<br>}
        if not (page/2 = []) [
            if (to-string page/1) <> homepage [
                current-path: rejoin [
                    current-path
                    { : <a href="./} (to-string page/1) {.html">} (to-string page/1) {</a>}
                ]
            ]
            foreach block page/2 [recurse block current-path]
        ]
    ]
    print {<center><table border="1" width=80% cellpadding="10"><tr><td>}
    recurse mymap: load %sitemap.r current-path
    print rejoin [{</td></tr></table><br><a href="./sitebuilder.cgi?name=} username {&pass=} password {&submit=submit">Back to Sitebuilder</a></center>}]
    if not exists? %index.html [
        write %index.html rejoin [{
            <html>
            <head>
            <title></title>
            <META HTTP-EQUIV="REFRESH" CONTENT="0; URL=./} (to-string mymap/1) {.html">
            </head>
            <body bgcolor="#FFFFFF"><div id="divId">
            </div>
            </body>
            </html>
        }]
    ]
    quit
]

;  Print instructions:

if submitted/6 = "instructions" [
    print {<pre>}
    print instructions: {
    REBOL WEB SITE BUILDER:

    This script enables you to easily create, edit, and arrange HTML pages on your web
    site.  The first step is to create and/or upload page content.  The built-in 
    WSYIWYG HTML editor allows you to layout pages visually, without having to write
    any code.  It works just like a word processor, except it runs directly in your
    browser, right on your web site.  You can adjust fonts, colors, and all essential
    formatting/layout options.  You can add tables, images, links, and other elements,
    all without writing any code.  Of course, if you prefer to write your own HTML code
    or copy/paste from other sources, you can switch instantly between visual and code
    view, for complete control and instant preview.  The built-in file upload allows
    you to upload any HTML files, scripts, images, or binary files of any sort,
    from any computer.  The template system automatically builds menu links to other
    pages, using a simple and quick site map layout that you specify, and the generated
    pages are all wrapped in templates that you can upload or create/edit directly online
    (2 generic templates are included to get you started).  Because this whole system
    runs in your browser, you can add pages, upload files, and edit site content
    instantly from any location, using any OS, without installing any software.


    CREATING AND EDITING PAGES:

    To create a new page for your web site, simply type in a name for the page and click
    the "Create New Page" link.  The visual editor will open, and you can begin editing
    content.  You can create new pages from scratch or copy/paste content directly into
    the visual view.  Page names should NEVER CONTAIN SPACES (use underscores instead),
    and should not have any file extensions.  It's suggested that title case be used for
    page names (every important word capitalized).

    To upload images, scripts, or any other content that you've created on your local 
    computer, simply click the "Choose" button and then the "Upload" button. 

    You can edit any text or code on a page, whether it was created using the online editor,
    or uploaded, by simply clicking the file name in "Edit Existing Pages".  To add an
    image to a page, simply click the image icon and type in the file name of any image
    that you've uploaded.  Adding, editing, and previewing scripts is as simple as clicking
    the HTML/Text button, and using the built-in preview button.  Centering and aligning
    content, changing font sizes, styles and colors, creating bulleted lists, and all 
    typical operations function just like they do in  most word processors.  Just select
    items and click on the icons to adjust your layout.  It's all very easy and intuitive,
    even for absolute beginners.


    THE SITE MAP:

    When you are done editing/uploading content pages, you will be asked if you want to add
    them as SUB-PAGES of other pages on your site.  A site map is automatically generated,
    and published pages contain automatically generated menus which enable users to easily
    navigate around your site.  The site map can be edited to easily arrange page links on
    your site, based on the simple sub-page layout.  Any page content added to the site map
    is also automatically framed in nicely designed templates, to give your entire site a
    consistent look and feel.

    If you want to edit the order of pages in your site map, or add/remove pages from your
    site, click the "Edit Site Map" link.  Starting with the home page, every entry in your
    site map is simply a BLOCK containing 2 items: 
 
    SOURCE FILE NAME:

        This is a file name containing page content that you've created, which you want
        to appear in an .html page of the same name on your site.  Content file names should
        be listed exactly as they were named when creating or uploading them, as they appear
        in the edit list.  In the site map, all source file names MUST BE PRECEDED BY A
        PERCENT SYMBOL ("%").

    SUB-PAGE LINKS: 

        Each page entry in your site map must be followed by a pair of square brackets.
        These brackets contain a block of links to other pages on the site, to appear in a
        link menu on the current page.  The home page can contain as many sub-pages (menu 
        links) as you want, and any sub-pages can contain as many sub-page links as you want,
        and so on, for as many levels deep as you want.  

    Your site map must have one and only one "home" page.  It can be any file name you've
    created - typically "Home" (a %Home file is automatically created when this script is
    first run).  This script automatically creates an index.html page that forwards to
    your home page, if no index.html exists.  It's recommended that you keep your home page
    file named "Home".

    Here's an example of how your site map would look if you only wanted one page to appear
    on your web site, labeled "Home.html":

    %Home []

    The file name (%Home above) contains the name of a source file to be processed (a 
    content file that you've previously uploaded or created with the built-in editor).
    The block following it (empty above) contains the names of any SUB-PAGES that will
    be processed and automatically linked to it (none in the case above).

    Below is an example of how the site map would look if you wanted a site made up of a
    home page and two sub-pages.  Home.html, Page_One.html and Page_Two.html would all be
    created from the source files listed, and a menu bar would be automatically generated
    and placed on Home.html, linking to the 2 other pages.  Neither Page_One.html nor
    Page_Two.html would contain any menu bars with links, because they don't contain any
    sub-pages:

    %Home [                         ; your home page (index.html forwards to it)
        [%Page_One []]              ; Page_One.html appears in the menu bar of Home.html
        [%Page_Two []]              ; Page_Two.html appears in the menu bar of Home.html
    ]

    The next example site map below contains a home page with 5 sub pages, the 3rd of
    which contains 2 sub pages, and the 2nd of that contains 3 sub pages.  In the
    generated .html pages, link menus are only placed on pages which have sub-pages (i.e.,
    only Home.html, Page_Three.html and Page_Three_B.html below would contain link menus):

    %Home [                      ; your home page
        [%Page_One []]           ; Page_One.html appears in the menu bar of Home.html
        [%Page_Two []]           ; Page_Two.html appears in the menu bar of Home.html
        [%Page_Three [           ; Page_Three.html appears in the menu bar of Home.html
            [%Page_Three_A []]   ; Page_Three_A.html appears in the menu bar of Page_Three_A.html
            [%Page_Three_B [     ; Page_Three_B.html appears in the menu bar of Page_Three_B.html
                [%Page_3_B_1 []] ; Page_3_B_1.html appears in the menu bar of Page_Three_B.html
                [%Page_3_B_2 []] ; Page_3_B_2.html appears in the menu bar of Page_Three_B.html
                [%Page_3_B_3 []] ; Page_3_B_3.html appears in the menu bar of Page_Three_B.html
            ]]
        ]]
        [%Page_Four []]          ; Page_Four.html appears in the menu bar of Home.html
        [%Page_Five []]          ; Page_Five.html appears in the menu bar of Home.html
    ]

    The key to understanding the site map is that any source file names followed by a 
    link block will contain an auto-generated menu of links to those sub-pages in the
    created .html file.  Pages without link blocks do not contain any sub-page links.
    They are simply wrapped in a template.  Of course, you can manually link to any page
    that you've created, if you don't want any auto-generated link menus or template
    design to appear on your site.  You can use this script to simply upload content,
    or to create/edit HTML/script files.  If that's the case, you don't need to create
    a site map.

    Once you've finished creating content files, and have arranged them into a site map,
    simply click the "Build Site" link.  You can then view the generated web site by
    clicking the "View Home Page" link.


    OTHER FEATURES:

    If you need to perform any file or OS operations, click the "Console" link.  You can
    run operating system commands using the following format (replace "dir" with any OS
    command):

        call {dir}

    You can also use the console to run any REBOL functions/scripts (for any sort of batch
    file operations, text searches, to download file/directories from other FTP sites, etc.).
    This adds enormous power to the system:

        rename %oldfile.txt %newfile.txt
        delete %unwanted_file.txt
        foreach file (read ftp://u:%p--site--com/) [write file read (join http://site.com/ file)]
        (You can perform almost any non-interactive operation possible in the REBOL console)

    During use, backups are automatically created of any file which is edited using the
    built-in editor (saved in the %./edit_history subfolder), so you can always easily fix
    mistakes or revert to previous versions of a page or site map.  It's all extremely SIMPLE
    and QUICK to implement and use.  New users can learn the system in a matter of minutes
    (the syntax pattern for editing the site map is the only thing that requires any thought
    whatsoever, and that's only necessary if you want to make _changes_ to the site layout).


    INSTALLATION:

    To install, just copy this script and an appropriate REBOL interpreter to your web server,
    (version 2.76+ is required for console operations), set permissions and the shebang line
    of this script, then start adding/editing pages to your site.


    TEMPLATE FILES (for advanced users):

    Two generic page templates are built into this script, but ANY HTML template can be added
    and used on your site.  Template files are simply HTML files that act as a "frame" for new
    content that you create with this script.  They can be edited to radically change the look, 
    feel, and design of destination .html files generated by this script.

    Templates are extremely simple to create.  They can be created/edited directly online using
    the built-in editor, or uploaded and edited later using this script.  IMPORTANT:  Code files
    such as templates should be edited using the plain text editor (with no visual WYSIWYG),
    available by clicking the "Files" link, next to the "Upload" button on the main page of this
    script.

    NOTE:  The built-in templates insert a header image at the top of every page (%header.jpg
    by default).  If you want to use the built-in templates, you can simply upload a header
    image to appear at the top of every page in your site.  Just create your own image, save it
    as "header.jpg" and use the built-in upload facility to upload it to your web site.  That's
    all you need to do to create a minimally unique design for different sites.  If you do this,
    try to keep the header.jpg image download size small.  You can reduce the .jpg quality and
    number of colors in your image editing software.  The shape of a header image should be like
    a banner - avoid letting it get too wide or too tall, or it will take up too much screen
    real estate on your site (500x100 pixels is a good ball park size for the built in templates).

    Templates contain 4 short lines of code that indicate where the source file text/code should
    be placed on your destination pages, and where the link menu should be placed on pages with
    sub-page link blocks.  You can use existing HTML pages to create templates or create
    completely new designs for every web site.  To make them work with this script, simply insert
    the codes below where you want the content to appear on generated destination pages:

    sitebuilder_title     ; Page title in head tag  ** By default same as the source file name **
    sitebuilder_links     ; Link menu(s) generated by this script (as defined in your site map)
    sitebuilder_path      ; Links through the hierarchy of sub-pages, back to your home page
    sitebuilder_content   ; All of the data contained in the source file of each content page

    There are two main types of templates:  those with menu bars, and those without.  The built-
    in template %menu.tpl displays a menu of links on the left side of the page (each with a text
    rollover effect).  The %menu.tpl file is used for any source pages that have ONE OR MORE sub-
    page(s) in the link block.  The built-in %nomenu.tpl template is used for pages with EMPTY
    link blocks.  You can edit the built-in template files, or create new HTML templates from 
    scratch.  It literally takes just a few seconds to create template files from existing HTML
    pages.  Examine the built in templates to see how it works - it's very straightforward.
    Simply name your templates menu.tpl and nomenu.tpl, then upload them to the folder on your
    server which contains this script.  
    }
    print {<pre>}
    quit
]

quit