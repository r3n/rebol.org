REBOL [
    title: "CGI FTP Folder Copy"
    date: 18-Apr-2010
    file: %cgi-ftp-folder-copy.r
    author:  Nick Antonaccio
    purpose: {
        A CGI script to copy entire directories of files from one web server to another. 
        Taken from the tutorial at http://re-bol.com
    }
]

#!/home/path/public_html/rebol/rebol -cs
REBOL []
print "content-type: text/html^/"
print [<HTML><HEAD><TITLE>"wgetter"</TITLE></HEAD><BODY>]
foreach file (read ftp://user:pass@site.com/public_html/path/) [
    print file
    print <BR>
    write/binary (to-file file) 
        (read/binary (to-url (rejoin [http://site.com/path/ file])))
]
print [</BODY></HTML>]