REBOL [
    Title: "Sends Email via CGI Form"
    Date: 20-Jul-1999
    File: %cgiemailer.r
    Purpose: "Uses a Web form to send an email message."
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [cgi email] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

print "Content-Type: text/html^/"  ;-- Required Page Header

print "<html><body><h2>Results:</h2>"

cgi: make system/standard/email decode-cgi system/options/cgi/query-string

either all [
    email? try [cgi/to: load cgi/to]
    email? try [cgi/from: load cgi/from]
][
    print [<B> "Sending Email to" cgi/to </B>]
    send/header cgi/to cgi/content cgi
][
    print "<B>Invalid email to or from address</B>"
]

print "</body><html>"



