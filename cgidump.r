REBOL [
    Title: "CGI Form Dumper"
    Date: 19-Jul-1999
    File: %cgidump.r
    Purpose: {
        Display the contents of a submitted form as a web page.
        Useful for debugging CGI forms.
    }
    Notes: {
        See the cgiform.r file for server instructions.
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

cgi: make object! decode-cgi system/options/cgi/query-string

print [<html><body><h2>"CGI Form Results:"</h2>]

foreach name next first cgi [print [name "is" <B> cgi/:name </B><P>]]

print [</body><html>]




