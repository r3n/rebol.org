REBOL [
    Title: "rmoocks"
    Date: 12-Jan-2002/2:21:06+1:00
    Version: 1.0.0
    File: %rmoocks.r
    Author: "SuperTomato"
    Purpose: {Emulates, with a few lines of Rebol code, the "CommServer" flash XML socket 
server from Moock and Clayton.(see www.moock.org for the flash client.)
The server sends a simple xml doc like <NUMCLIENTS>numclients</NUMCLIENTS>
as soon as someone enters or leaves the server.
By updating and comparing the old and updated value of numclients, The Flash
client knows if someone has entered or left the room. Plus: if a numclient is
received as the text field is empty, the client displays its welcome message.
Simple and efficient :)
This script adds a user limit feature.
I am currently discovering Rebol and try to use it with Flash.
This is my first script, be indulgent :)
My current project is a flash multiuser socket server handling
advanced options (rooms and user variables storage).
****************************************************************************************
Special thanks to Olivier Auverlot, check his website: http://rebolfrance.multimania.com
****************************************************************************************
}
    Email: yvan.touzeau@wanadoo.fr
    Web: http://www.supertomato.net
    library: [
        level: none 
        platform: none 
        type: none 
        domain: [tcp other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

print "**********************************"
print "*  Rebolized Flash Moock server  *"
print "**********************************"
print ""
print "listening on port 8000"
print ""

; EOM stores the message delimiter (End Of Message)
EOM: "^@"
; prints messages to console.
verbose: false
; opens port
io-port: open/no-wait tcp://:8000
; stores clients
clients: []
; numbers of clients
nc: 0
; max clients limit
mc: 10

broadcast: make function! [ mystring ] [
    to-string mystring
        clients: head clients
        foreach receipt clients [
        if error? try [ insert receipt/port mystring ]
        [ toconsole rejoin  [ "error while sending to client number " i ]]
            ]
    clients: head clients
]

toconsole: make function! [ mystring ] [if verbose [print rejoin [ ">>> " (to-string now) " <<< " mystring ]]]

forever [

either none? (wait [ 0 io-port])
            [ clients: head clients ] [
            toconsole "a user is connecting"
            either ( nc < mc ) [
            append clients make object! [
                        port: first io-port
                            ]
            nc: nc + 1
            broadcast rejoin [ "<NUMCLIENTS>" nc "</NUMCLIENTS>" EOM ]
            ]   [
                toconsole "max users limit reached, server refusing connection"
                new: first io-port
                insert new "<USER>%20REBOL Server</USER><MESSAGE>Sorry, maximum number of users reached :(</MESSAGE>^@"
                close new
                ] ]

while [ ( length? clients ) > 0 ] [

client: first clients
buffer: copy ""

  until [
    data: copy ""
    len: read-io client/port data 255
    append buffer data
    any [ ( found? find data EOM ) ( len < 1 ) ]
    ]

 either (buffer <> "")  [
            toconsole buffer
            broadcast buffer
            ]
            [ if ( len = 0 ) [
    close client/port
    remove clients
    nc: nc - 1
    toconsole "a user has left"
    broadcast rejoin [ "<NUMCLIENTS>" nc "</NUMCLIENTS>" EOM ]
        ] ]

    clients: next clients

    ]
]
                                                                                                          