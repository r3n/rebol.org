REBOL [
    Title: "CGI Form Emailer"
    Date: 19-Jul-1999
    File: %cgimail.r
    Purpose: {
        Emails the contents input into a web CGI form.
    }
    Notes: {
        Be sure to setup your email networking configuration
        to provide an SMTP and default email return address.
        The -cs option is needed to allow the SEND to happen.
    }
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [cgi email other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

print "Content-Type: text/plain^/"  ;-- Required Page Header

send luke@rebol.net decode-cgi system/options/cgi/query-string

print "Email sent."
