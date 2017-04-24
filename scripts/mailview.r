REBOL [
    Title: "Email Viewer (as web page)"
    Date: 10-Sep-1999
    File: %mailview.r
    Purpose: {
        This example displays all of your pending email
        as an HTML web page. (But does not remove it.)
    }
    Note: {
        Does not remove the mail from the server.
        See the popspec.r file for examples of how
        to setup your mailbox connection.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [email markup other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

html: make string! 10000  ; where new page is stored
emit: func [data] [append html reduce data]

inbox: open load %popspec.r  ;file contains POP email box info

emit [
    <html><body>
    <center><H3>"Mailbox Summary for " now/date " " now/time </H3>
    length? inbox " message(s)" </center><p>
    <table border="1" width="100%">
]

forall inbox [
    mail: import-email first inbox
    emit [
        <tr></tr>
        <tr><td>"From:"</td><td><b> first mail/from </b></td></tr>
        <tr><td>"Subject:"</td><td><b> mail/subject </b></td></tr>
        <tr><td>"Length:"</td><td> length? mail/content </td></tr>
        <tr><td></td><td><pre> mail/content </pre></td></tr>
    ]
]

emit [</table><p></body></html>]
close inbox
write %inbox.html html
