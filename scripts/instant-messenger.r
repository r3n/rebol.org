Rebol [
    title: "Peer to Peer Instant Messenger"
    date: 29-june-2008
    file: %instant-messenger.r
    purpose: {
        Exchange text messages directly via TCP/IP network port.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

connected: false
insert-event-func closedown: func [face event] [
    either event/type = 'close [
        if connected [
            insert port trim {
                *************************************************
                AND RECONNECT.
                YOU MUST RESTART THE APPLICATION
                TO CONTINUE WITH ANOTHER CHAT,
                THE REMOTE PARTY HAS DISCONNECTED.
                *************************************************
            }
            close port
            if mode/text = "Server Mode" [close listen]
        ]
        quit
    ] [event]
]

view/new center-face gui: layout [
    across
    at 5x2  ; this code positions the following items in the GUI
    text bold "Save Chat" [
        filename: to-file request-file/title/file/save trim {
            Save file as:} "Save" %/c/chat.txt
        write filename display/text 
    ]
    text bold "Lookup IP" [
        parse read http://whatsmyip.org/ [
            thru <title> copy my-ip to </title>
        ]
        parse my-ip [
            thru "Your IP is " copy stripped-ip to end
        ]
        alert to-string rejoin [
            "External: " trim/all stripped-ip "  "
            "Internal: " read join dns:// read dns://
        ]
    ]
    text bold "Help" [
        alert {
        Enter the IP address and port number in the fields
        provided.  If you will listen for others to call you, 
        use the rotary button to select "Server Mode" (you
        must have an exposed IP address and/or an open port
        to accept an incoming chat).  Select "Client Mode" if
        you will connect to another's chat server (you can do
        that even if you're behind an unconfigured firewall, 
        router, etc.).  Click "Connect" to begin the chat. 
        To test the application on one machine, open two
        instances of the chat application, leave the IP set
        to "localhost" on both.  Set one instance to run as 
        server, and the other as client, then click connect.
        You can edit the chat text directly in the display
        area, and you can save the text to a local file.
        }
    ]
    return
    lab1: h3 "IP Address:"  IP: field "localhost" 102
    lab2: h3 "Port:" portspec: field "9083" 50
    mode: rotary 120 "Client Mode" "Server Mode" [
        either value = "Client Mode" [
            show lab1 show IP
        ][
            hide lab1 hide IP
        ]
    ]
    cnnct: button red "Connect" [
        hide cnnct
        either mode/text = "Client Mode" [
            if error? try [
                port: open/direct/lines/no-wait to-url rejoin [
                    "tcp://" IP/text ":" portspec/text]
            ][alert "Server is not responding." return]
        ][
            if error? try [
                listen: open/direct/lines/no-wait to-url rejoin [
                    "tcp://:" portspec/text]
                wait listen
                port: first listen
            ][alert "Server is already running." return]
        ]
        focus entry
        connected: true
        forever [
            wait port
            foreach msg any [copy port []] [
                display/text: rejoin [
                    ">>>  "msg newline display/text]
            ]
            show display
        ]
    ]
    return  display: area "" 537x500
    return  entry: field 428  ; the numbers are pixel sizes
    button "Send Text" [
        if connected [
            insert port entry/text focus entry
            display/text: rejoin [
                "<<<  " entry/text newline display/text]
            show display
        ]
    ]
]

show gui do-events 