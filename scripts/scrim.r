REBOL [
    Title: "SCRIM (Simple Console Rebol Instant Messenger)"
    Date: 2-Jun-2001/21:22-7:00
    Version: 0.6.0
    File: %scrim.r
    Author: "Ryan S. Cole"
    Purpose: "RIM for those without View"
    History: [
    0.5.2 "Forcing update of RIM-Bot." 
    0.6.0 "Return bug fixed!" 
    "Greet fixed!" 
    {Changed 'load-thru to 'do as Core has no 'load-thru} 
    "/With now returns proper results" 
    {Very special thanks to Larry Morgenweck for all the help!}
]
    Email: ryanc@iesco-dms.com
    Web: http://www.sonic.net/~gaia/RIM/rim-bot.html
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

Print {----------< SCRIM >----------

Type "/Help" for assistance.
}

do http://www.reboltech.com/library/scripts/rim-bot.r

RIM-Bot/name: replace/all copy user-prefs/name " " "%20"
RIM-Bot/Welcome-msg: reform [ "Hello from" user-prefs/name ]
RIM-Bot/port: 7060
RIM-Bot/Init

list-users: does [
    foreach user extract RIM-bot/user-list 4 [ print user ]
]

call: function [
    "Connect to someone."
    who
] [
    buddy
] [
    either buddy: RIM-Bot/call who [
        print ["Connected to:" who]
        RIM-Bot/speak/to reform [user-prefs/name "is here."] buddy 
    ] [
        print ["Could not connect to:" who]
    ]
]

disconnect: func [
    "Disconnect someone."
    who
] [
    either RIM-Bot/disconnect who [
        print [who "disconnected"]
    ] [
        print ["who is" who ]
    ] 
]

set-greeting: func [ msg ] [
     RIM-Bot/Welcome-msg: reform [ "Hello from" user-prefs/name ]
     if not empty? msg [ 
          append RIM-Bot/Welcome-msg rejoin [ "^/" msg ] 
     ]
]

Show-connected: has [ user-name ] [
    foreach user RIM-Bot/Contacts [ 
        if user-name: RIM-Bot/who-is user [ print user-name ]
    ]
]

Whisper: func [user] [
    either user: RIM-Bot/who-is/port user [
        RIM-Bot/speak/to rejoin [user-prefs/name ": " ask "Message: "] user
    ] [
        Print ["Not connected to:" user]
    ]
]

help-msg: {
/Who        Show the user list.
/Quit       Quit the program.
/Call       Establish connection with a user.
/Bye        Disconnect from a user.
/With       Show connected users.
/Whisper    Speak to a certain connected user.
/Greet      Set greeting message.
/Help       What you see now.
/?          Same as /Help.
}

commands: [
    "/Who"     [ foreach user extract RIM-bot/user-list 4 [ print user ] ]
    "/Quit"    [ RIM-Bot/Shutdown  quit ]
    "/Call"    [ call ask "Contact which user? " ]
    "/Bye"     [ disconnect ask "Disconnect which user? " ]
    "/With"    [ Show-connected ]
    "/Whisper" [ Whisper ask "Whisper to: " ]
    "/Greet"   [ set-greeting ask "Enter a greeting message: " ]
    "/Help"    [ print help-msg ]
    "/?"       [ print help-msg ]
]

command?: func [
    text
] [
    #"/" = text/1
]

Forever [

    Anybody: RIM-Bot/listen/interupt

    if port? anybody [ 
        either Heard: RIM-Bot/hear Anybody [
            print Heard
        ] [
            Print [ any [rim-bot/whois Anybody  "Someone"] "just left." ]
        ]
    ]

    if input? [ 
        either command? was-said: input [
            switch/default was-said commands [ Print "I dont understand." ]
        ] [
            RIM-Bot/speak rejoin [user-prefs/name ": " was-said]
        ]
    ]
]