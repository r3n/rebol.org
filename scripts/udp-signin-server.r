REBOL [
    Title: "UDP Signin Server"
    date: 3-Aug-2010
    file: %udp-signin-server.r
    author:  Nick Antonaccio
    purpose: {
        Together with %udp-signin-client.r this program alerts users on a network
        that a new user has arrived and logged in.  Client users are only notified
        when the new user has signed in specificly to see them.  Because this script
        uses UDP, the client alarm application does not need to connect to any
        specific IP.  Anyone who runs the client on the local network will automatically
        receive notifications broadcast over the network.
        These scripts are simplified parts of a larger sign-in application that is used
        at my music lesson business.  When students arrive, they sign in at a front
        desk kiosk machine.  Student attendance information is logged, and the
        teachers get a voice announcement, in their studio, that their "next student
        has arrived" (they are only notified when one of their own students has arrived).
    }
]
net-out: open/lines udp://255.255.255.255:9905
set-modes net-out [broadcast: on]
svv/vid-face/color: white
previous-signin: copy []
sign-in: does [
    if ((f1/text = "") or (f2/text = "")) [return]
    current-signin: rejoin [f1/text " " f2/text]
    if current-signin = previous-signin [return]
    previous-signin: current-signin
    insert (at a1/text 1) rejoin [
        now/time {:    }
        "Student:  " f1/text {    }
        "Teacher:  " f2/text  newline
    ]
    show a1
    insert net-out current-signin
    write/append %alarm_history.txt rejoin [
        now 
        {  student: } f2/text 
        {  teacher: } f1/text newline
    ]
    attempt [
        insert s: open sound:// load %/c/windows/media/ding.wav
        wait s close s
    ]
    focus f1
]
view center-face layout [
    a1: area wrap join "Server started " now across
    text 60 "Name:"
    f1: field 332
    return
    text 60 "Teacher:"
    f2: field 332 [sign-in]
    return
    btn "Sign In" [sign-in]
    do [focus f1]
]