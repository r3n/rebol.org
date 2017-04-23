REBOL [
    title: "Kindle Email CGI Script" 
    date: 6-Nov-2011 
    file: %kindle-email.cgi 
    author: Nick Antonaccio 
    purpose: {
        This is a super simple email program which you can run on your web server
        to provide email access (read, send, delete, etc.) to multiple accounts, using
        the simplest of browsers.  This was written to be used on a Kindle with 3G
        access, and was actually written and implemented entirely on that Kindle,
        using nothing more than my console.cgi script, while on a trip where no other
        Internet access was available.

        INSTRUCTIONS:

        1) Remove this header (the first line of the script should be "#!./rebol276 -cs").
        2) Upload the REBOL interpreter and this script to your web server.
        3) In this script the REBOL interpreter file is named "rebol276", but that can be
            changed in the first line of the script, to whatever file name is given to the
            REBOL interpreter on your web server.
        4) CHMOD (change file permissions for) both files to 755.
        5) Edit your email account info, and type a desired username and password for
        the script, where indicated in the code. 
    } 
]


#!./rebol276 -cs
REBOL [Title: "Kindle Email"]
print {content-type: text/html^/^/}
print {<HTML><HEAD><TITLE>Kindle Email</TITLE></HEAD><BODY>}
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
if ((submitted/2 = none) or (submitted/4 = none)) [
    print {
        <STRONG>W A R N I N G  -  Private Server:</STRONG><BR><BR>
        <FORM METHOD="post" ACTION="./kindle-email.cgi">
            Username: <input type=text size="50" name="name"><BR><BR>
            Password: <input type=text size="50" name="pass"><BR><BR>
            <INPUT TYPE="SUBMIT" NAME="Submit" VALUE="submit">
        </FORM>
        </BODY></HTML>
    } 
    quit
]


; SET THIS ACCOUNT AND LOGIN INFO:
;_________________________________________________________________________
accounts: [
    ["pop.server1" "smtp.server1" "username1" "password1" you@site1.com]
    ["pop.server2" "smtp.server2" "username2" "password2" you@site2.com]
    ["pop.server3" "smtp.server3" "username3" "password3" you@site3.com]
]
myusername: "username"  mypassword: "password"
; ________________________________________________________________________


username: submitted/2   password: submitted/4 
either ((username = myusername) and (password = mypassword)) [][
    print "Incorrect Username/Password." 
    print {</BODY></HTML>} quit
]
if submitted/6 = "read" [
    account: pick accounts (to-integer submitted/8)
    mail-content: read [
        scheme: 'POP
        host: account/1
        port-id: 110
        user: account/3
        pass: account/4
    ]
    mail-count: length? mail-content
    for i 1 mail-count 1 [
        single-message: import-email (pick mail-content i)
        print rejoin [
            i {) &nbsp; <a href="./kindle-email.cgi?} 
            {u=} myusername {&p=} mypassword 
            {&subroutine=displaymessage&themessage=} 
            ; copy/part for URI length, at 3 is a serialization trick:
            at (mold compress (copy/part single-message/content 5000)) 3       
            {">} single-message/subject
            {</a> &nbsp; <a href="./kindle-email.cgi?} 
            {u=} myusername {&p=} mypassword 
            {&subroutine=delete&theaccount=} submitted/8
            {&thesubject=} single-message/subject 
            {&thedate=} single-message/date
            {&thefrom=} single-message/from {">delete</a>
            <br> &nbsp; &nbsp; &nbsp; &nbsp; } single-message/from {<br>}
        ]
    ]
    quit
]
if submitted/6 = "displaymessage" [
    compressed-message: copy join "#{" submitted/8
    print "<pre>"  print decompress load compressed-message  print "<pre>"
    quit
]
if ((submitted/6 = "send") or (submitted/6 = "delete")) [
    my-account: pick accounts (to-integer submitted/8)
    system/schemes/pop/host:  my-account/1
    system/schemes/default/host: my-account/2
    system/schemes/default/user: my-account/3 
    system/schemes/default/pass: my-account/4 
    system/user/email: my-account/5
] 
if submitted/6 = "send" [
    print "Sending..."
    header: make system/standard/email [
        To: to-email submitted/10
        From: to-email my-account/5
        Subject: submitted/12
    ]
    send/header (to-email submitted/10) (trim submitted/14) header
    print "<strong>Sent</strong>"
]
if submitted/6 = "delete" [
    mail: open to-url join "pop://" system/user/email
    while [not tail? mail] [
        pretty: import-email (copy first mail)
        either all [
            pretty/subject = submitted/10
            form pretty/date = submitted/12
            form pretty/from = submitted/14
        ][
            remove mail  print "<strong>Deleted</strong>"  wait 1
        ][
            mail: next mail
        ]
    ]
]
print {<hr><h2>Read:</h2>}
for i 1 (length? accounts) 1 [
    print rejoin [
        i {) &nbsp; <a href="./kindle-email.cgi?}
        {u=} myusername {&p=} mypassword {&subroutine=read&accountname=} 
        i {">} (first pick accounts i) {</a><br>}
    ]
]
print rejoin [
    {<BR><HR>
    <h2>Send:</h2>
    <FORM METHOD="post" ACTION="./kindle-email.cgi">
        <INPUT TYPE=hidden NAME="username" VALUE="} myusername {">
        <INPUT TYPE=hidden NAME="password" VALUE="} mypassword {">
        <INPUT TYPE=hidden NAME="subroutine" VALUE="send">
        From Account #: <select NAME="account">}
]
for i 1 (length? accounts) 1 [prin rejoin [{<option>} i]]
print {
        </option> </select><br><br>
        To: <BR><input type=text size="35" name="to"><BR><BR>
        Subject: <BR><input type=text size="35" name="subject"><BR><BR>
        <TEXTAREA COLS="50" ROWS="18" NAME="contents"></TEXTAREA><BR><BR>
        <INPUT TYPE="SUBMIT" NAME="Submit" VALUE="submit">
    </FORM>
    </BODY></HTML>
}
quit