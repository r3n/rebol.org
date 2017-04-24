REBOL [
    title: "WAP File Editor CGI"
    date: 10-Aug-2010
    file: %wap-file-editor.r
    author:  Nick Antonaccio
    purpose: {
        Edit text file (insert only) using your WAP cell phone browser.
    }
]

#!./rebol276 -cs
REBOL [title: "CGI WAP File Insert"]
submitted: decode-cgi system/options/cgi/query-string
prin {Content-type: text/vnd.wap.wml^/^/}
prin {<?xml version="1.0" encoding="iso-8859-1"?>^/}
prin {<!DOCTYPE wml PUBLIC "-//WAPFORUM//DTD WML 1.1//EN"
"http://www.wapforum.org/DTD/wml_1.1.xml">^/}
if submitted/2 = none [   
    print {<wml><card id="1" title="Select Teacher"><p>}
    print {Insert Text: <input name="thetext" size="12"/>}
    folders: copy []
    foreach folder read %./Teachers/ [
        if find to-string folder {/} [
            append folders to-string folder
        ]
    ]
    print {Teacher: <select name="teacher">}
    foreach folder folders [
        folder: replace/all folder {/} {}
        print rejoin [
            {<option value="} folder {">} folder {</option>}
        ]
    ]
    print {</select>
    <anchor>
       <go method="get" href="wapinsert.cgi">
           <postfield name="teacher" value="$(teacher)"/>
           <postfield name="thetext" value="$(thetext)"/>
       </go>
       Submit
    </anchor>}
    print {</p></card></wml>}
    quit
]
chosen-file: rejoin [%./Teachers/ submitted/2 "/schedule.txt"]
adjusted-file: read/lines chosen-file
insert next next next next adjusted-file submitted/4
write/lines chosen-file adjusted-file
count: 0
parse read join http://site.com/folders/ submitted/2 [
    thru submitted/2 copy p to "past students"
]
print {<wml>}
forskip p 130 [
    count: count + 1
    print rejoin [
        {<card id="} count {" title="} submitted/2 "-" count {"><p>}
    ]
    print rejoin [
        {<anchor>Next<go href="#} (count + 1) {"/></anchor>}
    ]
    print rejoin [{<anchor>Back<prev/></anchor>}]
    print copy/part p 130
    print {</p></card>}
]
print {</wml>}
quit