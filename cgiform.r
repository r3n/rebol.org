REBOL [
    Title: "Easy CGI Form Example"
    Date: 19-Jul-1999
    File: %cgiform.r
    Purpose: {Handles a CGI form and returns its values as a web page. (The associated cgiform.html file contains the form).}
    Notes: {
        Place this in your web server's cgi-bin directory.
        Set permissions to allow your server to run it.
        Modify the shell #! line above for correct path to REBOL.
        If you transfer this to your server from a PC,
        be sure to convert line terminators to those used
        by Unix -- REBOL doesn't care, but Unix does.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: 'cgi 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

print "Content-Type: text/html^/"  ;-- Required Page Header

cgi: make object! decode-cgi system/options/cgi/query-string

print [
    <html><body><h2>"CGI Results:"</h2>
    "Name:"  <B> cgi/name </B><P>
    "Email:" <B> cgi/email </B><P>
    "Phone:" <B> cgi/phone </B><P>
    </body><html>
]



