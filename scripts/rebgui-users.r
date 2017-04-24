REBOL [
    title: "RebGUI User List Demo"
    date: 24-Apr-2010
    file: %rebgui-users.r
    author:  Nick Antonaccio
    purpose: {
        A simple RebGUI demo.  Inspired by the tutorial at http://snappmx.com
        Taken from the tutorial at http://re-bol.com
    }
]

do load-thru http://re-bol.com/rebgui.r    ; Build#117  ; do %rebgui.r
unless exists? %snappmx.txt [
    save %snappmx.txt [
        "user1" "pass1" "Bill Jones" "bill@site.com" "Bill LLC" 
        "user2" "pass2" "John Smith" "john@mail.com" "John LLC"
    ]
]
database: load %snappmx.txt
login: request-password
found: false
foreach [userid password name email company] database [
    either (login/1 = userid) and (login/2 = password) [found: true] []
]
if found = false [alert "Incorrect Login." quit]
add-record: does [
    display/dialog "User Info" [
        text 20 "User:" f1: field return
        text 20 "Pass:" f2: field return
        text 20 "Name:" f3: field return
        text 20 "Email:" f4: field return
        text 20 "Company:" f5: field reverse
        button -1 #XY " Clear " [clear-fields]
        button -1 #XY " Add " [add-fields]
    ]
]
edit-record: does [
    display/dialog "User Info" [
        text 20 "User:" f1: field (form pick t/selected 1) return
        text 20 "Pass:" f2: field (form pick t/selected 2) return
        text 20 "Name:" f3: field (form pick t/selected 3) return
        text 20 "Email:" f4: field (form pick t/selected 4) return
        text 20 "Company:" f5: field (form pick t/selected 5) reverse
        button -1 #XY " Delete " [
            t/remove-row t/picked
            save %snappmx.txt t/data
            hide-popup
        ]
        button -1 #XY " Save " [
            t/remove-row t/picked
            add-fields
            save %snappmx.txt t/data
            hide-popup
        ]
    ]
]
add-fields: does [
    t/add-row reduce [
        copy f1/text copy f2/text copy f3/text copy f4/text copy f5/text
    ]
    save %snappmx.txt copy t/data
]
clear-fields: does [
    foreach item [f1 f2 f3 f4 f5] [do rejoin [{set-text } item {""}]]
]
table-size: system/view/screen-face/size/1 / ctx-rebgui/sizes/cell
display/maximize "Users" [
    t: table table-size #LWH options [
        "" left .0  "" left .0   ; don't show the first 2 fields
        "Name" center .33  "Email" center .34  "Company" center .34
    ] data database [edit-record]
    reverse
    button -1 #XY " Add " [add-record]
]
do-events