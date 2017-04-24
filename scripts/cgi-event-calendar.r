REBOL [
    title: "CGI Event Calendar"
    date: 18-Apr-2010
    file: %cgi-event-calendar.r
    author:  Nick Antonaccio
    purpose: {

        A web site CGI application that displays events in the current
        calendar month, with links to specified event pages.  Events
        are stored in the file %bb.db, in the format:

        ["event 1" 18-Apr-2010 http://website.com/event1.html]
        ["event 2" 20-Apr-2010 http://website.com/event2.html]
        ["event 3" 20-Apr-2010 http://website.com/event3.html]

        This script uses code derived from Bohdan Lechnowsky's "HTML calendar". 
        Taken from the tutorial at http://re-bol.com

    }
]

#! /home/path/public_html/rebol/rebol -cs
REBOL []
print "content-type: text/html^/"
print {<HTML><HEAD><TITLE>Event Calendar</TITLE></HEAD><BODY>}

bbs: load %bb.db
date: now/date
html: copy rejoin [
    {<CENTER><TABLE border=1 valign=middle width=99% height=99%>
        <TR><TD colspan=7 align=center height=8%><FONT size=5>}
    pick system/locale/months date/month {  } date/year
    {</FONT></TD></TR><TR>}
]

days: ["Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat"]
foreach day days [
    append html rejoin [
        {<TD bgcolor="#206080" align=center width=10% height=5%>
        <FONT face="courier new,courier" color="FFFFFF" size="+1">}
        day 
        {</FONT></TD>}
    ]
]
append html {</TR><TR>}

sdate: date  sdate/day: 0  
loop sdate/weekday // 7 + 1 [append html {<TD bgcolor=gray></TD>}]

while [sdate/day: sdate/day + 1 sdate/month = date/month][
    event-labels: {}
    foreach entry bbs [
        date-in-entry: 1-Jan-1001
        attempt [date-in-entry: (to-date entry/2)]
        if (date-in-entry = sdate) [
            event-labels: rejoin [
                {<font size=1>}
                event-labels 
                "<strong><br><br>"
                {<a href="} to-string entry/3 {" target=_blank>}
                entry/1 
                {</a>}
                "</strong>"
                {</font>}
            ]
        ]
    ]
    append html rejoin [
        {<TD bgcolor="#}
        either date/day = sdate/day ["AA9060"]["FFFFFF"]
        ; HERE, THE EVENTS ARE PRINTED IN THE APPROPRIATE DAY:
        {" height=14% valign=top>} sdate/day event-labels
        {</TD>}
    ]
    if sdate/weekday = 6 [append html {</TR><TR>}]
]

loop 7 - sdate/weekday [append html rejoin [{<TD bgcolor=gray></TD>}]]

append html {</TR></TABLE></CENTER></BODY></HTML>}
print html