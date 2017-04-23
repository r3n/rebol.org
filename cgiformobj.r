REBOL [
    Title: "CGI Form with Defaults"
    Date: 19-Jul-1999
    File: %cgiformobj.r
    Purpose: {
        Handles a CGI form, providing default values for
        missing fields in the form.  Returns a web page.
        (The associated cgiform.html file contains the form).
    }
    Notes: {
        This approach is a recommended practice.
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
        domain: [cgi markup other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

print "Content-Type: text/html^/"  ;-- Required Page Header

cgi-form: make object! [  ;-- Default form values.
    name:  "no-name"
    email: none
    phone: none
    date:  now
]

cgi: make cgi-form decode-cgi system/options/cgi/query-string

print [
    <html><body><h2>"CGI Results:"</h2>
    "Name:"  <B> cgi/name </B><P>
    "Email:" <B> cgi/email </B><P>
    "Phone:" <B> cgi/phone </B><P>
    "Date:"  <B> cgi/date </B><P>
    </body><html>
]



