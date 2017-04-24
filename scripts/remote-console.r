REBOL [
    title: "CGI Remote Console"
    date: 26-sep-2009
    file: %remote-console.r
    purpose: {
       Allows you to type REBOL code into an HTML text area, and have
       that code execute directly on your web server.  The results of the 
       code are then displayed in your browser.  This essentially functions
       as a remote console for the REBOL interpreter on your server.  You
       can use it to run REBOL code, or to call shell programs directly on
       your web site.  DO NOT run this on your web server if you're 
       concerned at all about security!
       Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

#! /home/path/public_html/rebol/rebol276 -cs
REBOL [Title: "REBOL CGI Console"]
print "content-type: text/html^/"
print {<HTML><HEAD><TITLE>Console</TITLE></HEAD><BODY>}
selection: decode-cgi system/options/cgi/query-string

; If no data has been submitted, print form to request user/pass:

if ((selection/2 = none) or (selection/4 = none)) [
    print {
        <STRONG>W A R N I N G  -  Private Server, Login Required:</STRONG>
        <BR><BR>
        <FORM ACTION="./console.cgi">
        Username: <INPUT TYPE=text SIZE="50" NAME="name"><BR><BR>
        Password: <INPUT TYPE=text SIZE="50" NAME="pass"><BR><BR>
        <INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">
        </FORM>
    }
    quit
]

; If code has been submitted, print the output:

qq: [
    print {
        <CENTER><FORM METHOD="get" ACTION="./console.cgi">
        <INPUT TYPE=hidden NAME=submit_confirm VALUE="command-submitted">
        <TEXTAREA COLS="100" ROWS="18" NAME="contents"></TEXTAREA><BR><BR>
        <INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">
        </FORM></CENTER></BODY></HTML>
    }
]

if selection/2 = "command-submitted" [
    write %commands.txt join "REBOL[]^/" selection/4
    ; The "call" function requires REBOL version 2.76:
    call/output/error 
        "/home/path/public_html/rebol/rebol276 -qs commands.txt"
        %conso.txt %conse.txt
    print rejoin [
        {<CENTER>Output: <BR><BR>}
        {<TABLE WIDTH=80% BORDER="1" CELLPADDING="10"><TR><TD><PRE>}
        read %conso.txt
        {</PRE></TD></TR></TABLE><BR><BR>}
        {Errors: <BR><BR>}
        read %conse.txt
        {</CENTER>}
    ]
    do qq
    quit
]

; Otherwise, check submitted user/pass, then print form for code entry:

username: selection/2 password: selection/4 
either (username = "user") and (password = "pass") [
    ; if user/pass is ok, go on
][
    print "Incorrect Username/Password." quit
]

do qq