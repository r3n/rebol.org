REBOL [
    title: "File Download CGI"
    date: 10-Aug-2010
    file: %file-download-cgi.r
    author:  Nick Antonaccio
    purpose: {
        Push file download from web server to browser.
    }
]

#! ./rebol -cs
REBOL [title: "CGI File Downloader"]
submitted: decode-cgi system/options/cgi/query-string
root-path: "/home/path"
if ((submitted/2 = none) or (submitted/4 = none)) [
    print "content-type: text/html^/"
    print [<STRONG>"W A R N I N G  -  "]
    print ["Private Server, Login Required:"</STRONG><BR><BR>]
    print [<FORM ACTION="./download.cgi">]
    print [" Username: " <INPUT TYPE=text SIZE="50" NAME="name"><BR><BR>]
    print [" Password: " <INPUT TYPE=text SIZE="50" NAME="pass"><BR><BR>]
    print [" File: "<BR><BR>]
    print [<INPUT TYPE=text SIZE="50" NAME="file" VALUE="/public_html/">]
    print [<BR><BR>]
    print [<INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">]
    print [</FORM>]
    quit
]
username: submitted/2 password: submitted/4 
either (username = "user") and (password = "pass") [
    ; if user/pass is ok, go on
][
    print "content-type: text/html^/"
    print "Incorrect Username/Password." quit
]
print rejoin [
    "Content-Type: application/x-unknown"
    newline
    "Content-Length: "
    (size? to-file join root-path submitted/6) 
    newline
    "Content-Disposition: attachment; filename=" 
    (second split-path to-file submitted/6)
    newline
]
data: read/binary to-file join root-path submitted/6
data-length: size? to-file join root-path submitted/6
write-io system/ports/output data data-length