REBOL [
    title: "Remove Unwanted Emails CGI"
    date: 10-Aug-2010
    file: %remove-emails-cgi.r
    author:  Nick Antonaccio
    purpose: {
        Remove any emails from your POP account which contain specified
        snippets of text.
    }
]

#! /home/path/public_html/rebol/rebol -cs
REBOL [title: "CGI Remove Unwanted Emails"]
print "content-type: text/html^/"
print [<HTML><HEAD><TITLE>"Remove Emails"</TITLE></HEAD><BODY>]
spam: [
    {Failure} {Undeliverable} {failed} {Returned Mail} {not be delivered}
    {mail status notification} {Mail Delivery Subsystem} {(Delay)}
]
print "logging in..."
mail: open pop://user:pass@site.com
print "logged in"
while [not tail? mail] [
    either any [
        (find first mail spam/1) (find first mail spam/2)
        (find first mail spam/3) (find first mail spam/4)
        (find first mail spam/5) (find first mail spam/6)
        (find first mail spam/7) (find first mail spam/8)
    ][
        remove mail
        print "removed"
    ][
        mail: next mail        
    ] 
    print length? mail 
]
close mail
print [</BODY></HTML>]
quit