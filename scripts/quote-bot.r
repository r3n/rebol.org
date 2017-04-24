REBOL [
    Title: "Quote bot"
    Date: 1-Jun-2001/11:03:58-7:00
    Version: 1.0.0
    File: %Quote-bot.r
    Author: "Ryan S. Cole"
    Purpose: "Runs a rugby request to a quote server."
    Email: ryanc@iesco-dms.com
    library: [
        level: none 
        platform: none 
        type: none 
        domain: [tcp ldc] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Print "Quote bot"

do load-thru http://www.reboltech.com/library/scripts/rim-bot.r
do load-thru http://www.reboltech.com/library/scripts/rugby.r

RIM-Bot/name: "Quote-bot"
RIM-bot/welcome-msg: {Type "Help" for a list of commands.}
RIM-Bot/port: "7070"
RIM-Bot/Init

Forever [
    print Heard: RIM-Bot/hear Whom: RIM-Bot/listen
    if Heard [ 
        error? try [ 
            rv: rugby-client/rexec/with probe to-block find/tail line ": "  make port! tcp://206.229.23.41:8001
            if all [ "" <> first rv  not none? first rv ] [
                 RIM-Bot/speak/to trim to-string rv Whom
                 print rv
            ]
        ]
    ]
]