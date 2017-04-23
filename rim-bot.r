REBOL [
    Title: "RIM Bot"
    Date: 1-Jun-2001/18:30-7:00
    Version: 0.6.0
    File: %rim-bot.r
    Author: "Ryan S. Cole"
    Purpose: {Provides easy to use interface into RIM (Rebol Instant Messenger) communications.}
    Email: ryanc@iesco-dms.com
    Web: http://www.sonic.net/~gaia/RIM/rim-bot.html
    Comments: {
        0.5.2  Change defualt Announce-Frequency to 00:00:30 from 00:00:01 to prevent collisions.
        0.6.0  Change who-is, returns none if not found instead of "someone".  Added new functionality to it too.
               Added Call function
               Added Disconnect function
               fixed listen/no-wait
    }
    library: [
        level: none 
        platform: none 
        type: 'tool 
        domain: [tcp ldc] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

RIM-Bot: Make Object! [
    name: "RIM-Bot"
    Welcoming: yes ; adds new connections to contacts automatically
    Welcome-msg: none
    Port:  "7070"
    Announce-site: http://www.reboltech.com/cgi/rebol
    Announce-frequency: 00:00:30

    Listen-port: none   
    then: now
    Contacts: [] ; People your talking to
    User-List: [] ; People on the RIM user list

    Init: does [
        Listen-port: open/lines rejoin [ tcp://: port ]
        Announce
    ]

    Announce: does [
        either error? try [
              User-List: load rejoin [
                announce-site
                "/lookup.r?cmd=post&service=chat&name=" name 
                "&data=" to-string port
              ] ] [ 
            none
        ] [
            User-List
        ]
    ]
    
    Shutdown: does [
        error? try [ read rejoin [ 
              announce-site
              "/lookup.r?cmd=remove&service=chat&name=" name
           ]
        ]
        error? try [ close listen-port ]
        foreach port contacts [ error? try [ close port ] ]
    ]

    Call: Function [
        "Establishes connection with user in user-list."
        Identifier [String! Tuple!]
    ] [
        info
    ] [
        info: who-is/info Identifier
        
        any [
            if block? info [
                if not error? try [append contacts open/lines rejoin [ tcp:// info/2 ":" info/4] ] [
                    last contacts
                ]
            ]
        ]
    ]

    Disconnect: Function [
        "Close connection with user."
        Identifier [String! Tuple! Port!]
    ] [
    ] [
        if port? Identifier [ error? try [ close Identifier ]  return True ]
        if none? Identifier: who-is/port Identifier [ return False ]
        error? try [ close Identifier ]  
        return True        
    ]

    Speak: function [
        "Send message to current contacts."
        msg "Message to send."
        /to Whom "Specified contact."
        /not-to Excluded "Do not speak to specified contact."
    ] [
    ] [
        either to [
            if not all [ not-to  Whom = Excluded ] [ Insert Whom msg ]
        ] [
            foreach person contacts [
                if not all [ not-to  person = excluded ] [
                    insert person msg
                ]
            ]
        ]
        msg
    ]

    Listen: Function [
        "Listen for messages, returns port."
        /to whom "Listen to a particular port."
        /interupt "Stop listening on console input." 
        /no-wait
    ] [
        speaker
        wait-on
        console
    ] [
        either to [ 
            wait-on: reduce [whom]
        ] [
            append wait-on: copy contacts reduce [listen-port]
        ]
        if interupt [ append wait-on make port! [ scheme: 'console ] ]
        append wait-on either no-wait [0] [Announce-frequency]
        until [
            if (now - Announce-frequency > then) [ announce  then: now ]
            something: wait wait-on
            if port? something [
                if something/scheme = 'console [ return none ]
                either something = listen-port [
                    speaker: first something
                    if welcoming [ append contacts speaker ]
                    if welcome-msg [ insert speaker welcome-msg ]
                ] [
                    speaker: something
                ]
            ]
            if any [ no-wait none? speaker ] [ return none ]
            speaker
        ]
    ]

    hear: function [
        "Reads a message from a port."
        Whom [Port! None!]
    ] [
        heard
    ] [
        if error? try [ heard: first whom ] [
            remove find contacts whom
        ]
        heard       
    ]

    Who-is: function [
        "Finds users name in users list."
        reference [port! string! tuple! none!]
        /Port "Find users port."
        /Info "Get user's information block."
    ] [
        rv
    ] [
        rv: any [
            if port? reference [ first back any [ find user-list reference/remote-ip [none] ] ]
            if tuple? reference [ first back any [ find user-list reference [none] ] ]
            if string? reference [ first any [ find user-list reference [none] ] ]
        ]
        if all [ rv  any [ Port  Info ] ] [        
            either rv: find user-list rv [rv: copy/part rv 4] [rv: none]
        ]
        if all [ rv  Port ] [
            rv: any [ foreach p contacts [ if p/remote-ip = rv/2 [ rv: p ] ] ]
        ]
        rv
    ]
]