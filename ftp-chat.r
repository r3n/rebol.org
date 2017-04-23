Rebol [
    title: "FTP Chat Room"
    date: 29-june-2008
    file: %ftp-chat.r
    purpose: {
        A simple chat application that lets users send instant text messages
        back and forth across the Internet.
        The chat "rooms" are created by dynamically creating, reading, 
        appending, and saving text files via ftp (to use the program, you'll
        need access to an available ftp server: ftp address, username, and
        password).
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

webserver: to-url request-text/title/default trim {Web Server Address:} {ftp://user:pass@website.com/public_html/chat.txt}
name: request-text/title "Enter your name:"
cls: does [prin "^(1B)[J"]
write/append webserver join now [": " name " has entered the room." newline]
forever [
    current-chat: read webserver 
    cls 
    print join "--------------------------------------------------" [
        newline {You are logged in as: } name newline 
        {Type "room" to switch chat rooms.} newline
        {Type "lock" to pause/lock your chat.} newline
        {Type "quit" to end your chat.} newline 
        {Type "clear" to erase the current chat.} newline 
        {Press [ENTER] to periodically update the display.} newline 
        "--------------------------------------------------" newline]
    print join "Here's the current chat text at: " [webserver newline]
    print current-chat 
    sent-message: copy join name [" says: " entered-text: ask "You say:  "] 
    switch/default entered-text [
        "quit"  [break] 
        "clear" [
            if/else request-pass = ["secret" "password"] [
                write webserver ""] [alert trim {
                You must know the administrator 
                password to clear the room!}
            ]
        ]
        "room"  [
            write/append webserver join now [
                ": " name " has left the room." newline]
            webserver: to-url request-text/title/default {New Web 
            Server Address:} to-string webserver
            write/append webserver join now [
                ": " name " has entered the room." newline
            ]
        ]
        "lock" [
            alert trim {The program will now pause for 5 seconds. 
                You'll need the correct username and password 
                to continue.}
            pause-time: now/time + 5  
            forever [if now/time = pause-time [
                while [request-pass <> ["secret" "password"]] [
                    alert "Incorrect password - look in the source!"
                    ]
                break
                ]
            ]
        ]
    ] [if entered-text <> "" [write/append webserver join sent-message [newline]]]
]
cls print "Goodbye!" 
write/append webserver join now [": " name " has closed chat." newline]
wait 1