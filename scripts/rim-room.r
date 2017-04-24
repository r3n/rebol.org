REBOL [
    Title: "RIM Room"
    Date: 1-Jun-2001/10:30-7:00
    Version: 1.0.4
    File: %rim-room.r
    Author: "Ryan S. Cole"
    Purpose: "An example chat room for RIM using RIM Bot."
    Email: ryanc@iesco-dms.com
    Web: http://www.sonic.net/~gaia/RIM/rim-bot.html
    Comments: {
        1.0.2  Changed do %rim-bot.r to use load-thru
        1.0.4  Changed to use the reboltech library
    }
    library: [
        level: none 
        platform: none 
        type: none 
        domain: [ldc tcp] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Print "RIM-Room"

do load-thru http://www.reboltech.com/library/scripts/rim-bot.r

RIM-Bot/name: "RIM-Room"
RIM-Bot/port: 7050
RIM-Bot/Init

Forever [
    probe Heard: RIM-Bot/hear Whom: RIM-Bot/listen
    Either Heard [ 
        RIM-Bot/speak/not-to Heard Whom 
    ] [
        RIM-Bot/speak reform [ RIM-Bot/Who-is Whom "just left." ]
    ] 
]