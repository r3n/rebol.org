REBOL [
    title: "WAP Mail Reader CGI"
    date: 10-Aug-2010
    file: %wap-mail-reader.r
    author:  Nick Antonaccio
    purpose: {
        Read email using your WAP cell phone browser.
    }
]

#!./rebol276 -cs
REBOL [title: "WAP Mail Reader CGI"]
submitted: decode-cgi system/options/cgi/query-string
prin {Content-type: text/vnd.wap.wml^/^/}
prin {<?xml version="1.0" encoding="iso-8859-1"?>^/}
prin {<!DOCTYPE wml PUBLIC "-//WAPFORUM//DTD WML 1.1//EN"
"http://www.wapforum.org/DTD/wml_1.1.xml">^/}
accounts: [
    ["pop.server" "smtp.server" "username" "password" you@site.com]
    ["pop.server2" "smtp.server2" "username" "password" you@site2.com]
    ["pop.server3" "smtp.server3" "username" "password" you@site3.com]
]
if ((submitted/2 = none) or (submitted/2 = none)) [   
    print {<wml><card id="1" title="Select Account"><p>}
    print {Account: <select name="account">}
    forall accounts [
        print rejoin [
            {<option value="} index? accounts {">}
            last first accounts {</option>}
        ]
    ]
    print {</select>
    <select name="readorsend">
        <option value="readselect">Read</option>
        <option value="sendinput">Send</option>
    </select>
    <anchor>
       <go method="get" href="wapmail.cgi">
           <postfield name="account" value="$(account)"/>
           <postfield name="readorsend" value="$(readorsend)"/>
       </go>
       Submit
    </anchor>}
    print {</p></card></wml>}
    quit
]
if submitted/4 = "readselect" [
    t: pick accounts (to-integer submitted/2)
    system/schemes/pop/host:  t/1
    system/schemes/default/host: t/2
    system/schemes/default/user: t/3 
    system/schemes/default/pass: t/4 
    system/user/email: t/5
    prin {<wml><card id="1" title="Choose Message"><p>}
    prin rejoin [{<setvar name="account" value="} submitted/2 {"/>}]
    prin {<select name="chosenmessage">}
    mail: read to-url join "pop://" system/user/email
    foreach message mail  [
        pretty: import-email message
        if (find pretty/subject "***SPAM***") = none [
            replace/all pretty/subject {"} {}
            replace/all pretty/subject {&} {}
            prin rejoin [
                {<option value="} 
                pretty/subject
                {">}
                pretty/subject
                {</option>}
            ]
        ]
    ]
    print {</select>
    <anchor>
       <go method="get" href="wapmail.cgi">
           <postfield name="subroutine" value="display"/>
           <postfield name="chosenmessage" value="$(chosenmessage)"/>
           <postfield name="account" value="$(account)"/>
       </go>
       Submit
    </anchor>
    </p></card></wml>}
    quit
]
if submitted/2 = "display" [
    t: pick accounts (to-integer submitted/6)
    system/schemes/pop/host:  t/1
    system/schemes/default/host: t/2
    system/schemes/default/user: t/3 
    system/schemes/default/pass: t/4 
    system/user/email: t/5
    prin {<wml><card id="1" title="Display Message"><p>}
    mail: read to-url join "pop://" system/user/email
    foreach message mail  [
        pretty: import-email message
        if pretty/subject = submitted/4 [
            replace/all pretty/content {"} {}
            replace/all pretty/content {&} {}
            replace/all pretty/content {3d} {}
            strip: copy ""
            foreach item (load/markup pretty/content) [
                if ((type? item) = string!) [strip: join strip item]
            ]
            prin strip
        ]
    ]
    print {</p></card></wml>}
    quit
]