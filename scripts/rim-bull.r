REBOL [
    Title: "RIM Bulliten"
    Date: 1-Jun-2001/10:30-7:00
    Version: 0.9.4
    File: %rim-bull.r
    Author: "Ryan S. Cole"
    Purpose: "A simple RIM bulletin board example using RIM Bot."
    Email: ryanc@iesco-dms.com
    Web: http://www.sonic.net/~gaia/RIM/rim-bot.html
    Comments: {
        0.9.2  Changed do %rim-bot.r to use load-thru
        0.9.4  Changed to load-thru reboltech library
               Fixed short listing bug
               Name mispelled
    }
    library: [
        level: none 
        platform: none 
        type: none 
        domain: 'tcp 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
do load-thru http://www.reboltech.com/library/scripts/rim-bot.r

Print "RIM-Bulletin"
Max-bulletins: 10
Bulletins: []
RIM-Bot/name: "Bulletins"
RIM-Bot/welcome-msg: {Simple Bulletin Board for RIM.  Type "help" for instructions.}

RIM-Bot/port: 5555
RIM-Bot/Init
cmds: [
    "post"  [
         append bulletins at Heard 6
         if Max-bulletins < length? bulletins [ remove head bulletins ]
         RIM-Bot/speak Heard
    ]
    "read"  [
         foreach bull bulletins [
             RIM-Bot/speak/to bull whom
         ]
    ]
    "help"  [
         RIM-Bot/speak/to {Three commands, Post <comments>, Read, and Help.} whom
    ]
]

Forever [
    Heard: RIM-Bot/hear Whom: RIM-Bot/listen
    if Heard [
        if heard: Find/tail heard ": " [ switch probe copy/part heard 4 cmds]
    ]
]