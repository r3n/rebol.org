#!/usr/local/bin/rebol -cs

REBOL [
  Title: "FormMail.pl Lookalike Spam Trap"
  File: %formmail.pl
  Author: "HY"
  History: [ 4-Oct-2004 "HY" "Made the script" ]
  Date: 4-Oct-2004
  Purpose: { Respond to a CGI calls as if we were FormMail.pl
             (See http://www.scriptarchive.com/formmail.html)
             If the request seems to be an openness check,
             respond with an email indicating this server is
             ready for abuse. Else, swallow spam email and
             return nothing.

             Note the filename - for once, a rebol script that
             does not end with the .r extension.
           }
  Library: [
    level: 'beginner
    domain: [http email other-net web cgi]
    license: none
    Platform: 'all
    Tested-under: none
    Type: [tool]
    Support: none
  ]
]

; set-net [email@your.server.com "your.server.com" "your.server.com" none none none]
send?: no
my-servers: [ "your.server.com"
            ] ; This should be the name of your servers.
              ; If one of these strings are found in the
              ; subject line, email will be passed on to the recipient!



query-object: make object! decode-cgi system/options/cgi/query-string



; Here's what FormMail 1.6 does (and we don't):
; 1 Check referer
; 2 Format today's date (we stick with rebol's format)
; 3 Parse input form (note: this is 86 lines in perl. In rebol, it's done with line 35 above).
; 4 Check that all required fields are filled in. We'll just check if the request is an openness check or not:

foreach server my-servers [ if attempt [find query-object/subject server] [send?: yes] ]


; Then it's time to write some HTML:

print join "Generated-by: " system/script/header/title
print "Pragma: no-cache"
print "Content-Type: text/html; charset=iso-8859-1^/"

print [
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 TRANSITIONAL//EN"> newline
  <HTML> newline
  <HEAD> <TITLE> system/script/header/title </TITLE> </HEAD> newline
  <BODY> <H1> "This is not an open FormMail.pl relay" </H1>
]

print either send? [
  [ <P> "But of course, you don't read this page anyway, you just check your email" </P> newline
    <P> "Please enjoy our service." </P> ]
] [
  [ <P> "Thank you. Your email is now swallowed and didn't even make it to the recipient's spam filter." </P> ]
]

print [
  </BODY> newline
  </HTML>
]

if send? [
  send/header to-email query-object/recipient to-string attempt [query-object/message] make object! [X-sender: system/script/header/title from: attempt [query-object/email] to: attempt [query-object/recipient] date: none subject: query-object/subject]
]

