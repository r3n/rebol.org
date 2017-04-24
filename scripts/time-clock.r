REBOL [
    title: "Time Clock"
    date: 16-Jan-2011
    file: %time-clock.r
    author:  Nick Antonaccio
    purpose: {
        Used to log hours worked by employees.  To help eliminate potential falsified
        hours, the program takes a photo of the employee each time they clock in
        and clock out, and sets the system clock using Ladislav Mercir's nist-clock.r
        This code is provided as-is, with no warranty expressed or implied.  Use
        it at your own risk.
        This script can also be found in the examples at http://re-bol.com/examples.txt.
    }
]

do decompress #{
789C6D544B6FDB300CBEFB57B005861D0ADB49BA6081D7B5971D765977688162
087C506D3AD1224B811E09BC61FF7D941C278A13388E2592FAF8FA44CB5B4C0D
EA1D6A53C032819A759664459EFB4FCA32C98DCD566A77A17ABFAAF2B2692ABB
CC199270B9CA945E5D18644C8974C732D3B52D5ACD2BD566F42665D2C7924A55
C024F1B66938078D93958FEFEF33921E9C41B06B6E82DC7225A1551A41351625
299804252B042EA1514E83C14AC9DADCFC4B2017AA62028ED0D0FEAE61DD9AA4
F4F04E5A2EFC02A2408E4BB88329A97813891E41A05CD9F513D8A896B08CCE4F
4B3A249505D45A6932D41D2CA3DC34B21AB6BCDA9C431C11E838FDB64C1BCC99
88635F9A0DDF42A5B65D48630E613FA30A6807B7F4041565078BA02298C8EFF4
73FEAC76F974315F50665651B92CAE50DF78B0C832EFCDC9C02F6E42B54E5A6A
5AA5B4C6D086D443E81D13D4BE62514C62558F22D51E52B872A2EFF649E111E8
3913637D4687432F351A276CE85FBFECBDDCC10831F19DBBE2191EBE42CD9B06
357AD2F418308A3C906280BFCCEA580D187B2DAE605378A1A7FD36D0DEA6A633
16DB8092EEB98C384F5AE8B5A1039ED66F5CD66A6FBE1084755AC2AB76415E31
E3AF01185755680C117E59315BAD4B7F072D1EF93F7238B05FD019A092387C82
8F1BD412C5FD0C96C3AA00A1589D0BFEAE1991F8C320CF6A21C8C308B480966D
2867E52C97C49B70AD82FA405EAB5D65495E96A1B63E111A42D416CF7838BABF
7D41FB12CEBDD2B9DB3E9322FC1395FC27FFA32426A765E04E021378781C07D5
C774744D8EF7BF90698A66ADB4770CFB1F4ADA752CF8C6BA9FCD1BE266248CB7
DFFD9C8941B8741663C94B1842E73642F0C36C3AC94B2A45EDAA9E7121A58E02
1CD6AD0F6ED8EC29261AADC3365A867BBBA698CE046D088A44F1653FA9FB5048
3DF1ECBC60254DC23D272E1D9A98FB29E5472FA3AC26997F66F3B97F7DE4BDE0
3E9BC2B2B8C2EE72B0F894CDAE58086F4183C5D12D9236BE64E7936064D128DD
422C0A792561609FB3E00AD661268F2650F91F6BB4707323070000
} ;  Ladislav Mecir's nistclock.r

make-dir img-dir: %./clock_photos/
unless exists? %employees [
    write %employees {"Nick Antonaccio" "(Add New...)"}
]
cur-employee: copy ""

avicap32.dll: load/library %avicap32.dll
user32.dll: load/library %user32.dll
find-window-by-class: make routine! [
    ClassName [string!] WindowName [integer!] return: [integer!]
] user32.dll "FindWindowA"
sendmessage: make routine! [
    hWnd [integer!] val1 [integer!] val2 [integer!] val3 [integer!]
    return: [integer!]
] user32.dll "SendMessageA"
sendmessage-file: make routine! [
    hWnd [integer!] val1 [integer!] val2 [integer!] val3 [string!]
    return: [integer!]
] user32.dll  "SendMessageA"
cap: make routine! [
    cap [string!] child-val1 [integer!] val2 [integer!] 
    val3 [integer!] width [integer!] height [integer!]
    handle [integer!] val4 [integer!] return: [integer!]
] avicap32.dll "capCreateCaptureWindowA"

log-it: func [inout] [
    if ((cur-employee = "") or (cur-employee = "(Add New...)")) [
        alert "You must select your name." return
    ]
    if set-system-time nist-corrected-time [nist-correction: 0:0]  
    cur-time: now
    record: rejoin [
        newline {[} mold cur-employee 
        { "} mold cur-time {" "} inout { "]}
    ]
    either true = request/confirm rejoin [
        record " -- IS YOUR NAME AND THE TIME CORRECT?"
    ] [
        write/append %time_sheet.txt record
        alert rejoin [
            uppercase copy cur-employee ", YOU ARE " inout "."
        ]
    ] [
        alert "CANCELED."
        return
    ]
    time-filename: copy replace/all copy to-string cur-time "/" "_"
    time-filename: copy replace/all copy time-filename ":" "+"
    img-file: rejoin [
        img-dir 
        (replace/all copy cur-employee " " "_")
        "_"
        time-filename "_" 
        next find inout " "
        ".bmp"
    ]
    sendmessage cap-result 1085 0 0
    sendmessage-file cap-result 1049 0 img-file
    call %scrshot.bmp
]

view/new center-face layout/tight [
    image 320x240
    tl1: text-list 320x200 data sort load %employees [
        cur-employee: value
        if cur-employee = "(Add New...)" [
            write/append %employees mold trim request-text/title "Name:"
            tl1/data: sort load %employees show tl1
        ]
    ]
    key #"^~" [
        del-emp: copy to-string tl1/picked
        temp-emp: sort load %employees
        if true = request/confirm rejoin ["REMOVE " del-emp "?"] [
            new-list: head remove/part find temp-emp del-emp 1
            save %employees new-list
            tl1/data: sort load %employees show tl1
            alert rejoin [del-emp " removed."]
        ]
    ]
    across
    btn "Clock In" [log-it "CLOCKED IN"]
    btn "Clock Out" [log-it "CLOCKED OUT"]
    btn "EXIT" [
        sendmessage cap-result 1205 0 0
        sendmessage cap-result 1035 0 0
        free user32.dll   quit
    ]
]

hwnd: find-window-by-class "REBOLWind" 0
cap-result: cap "cap" 1342177280 0 0 320 240 hwnd 0
sendmessage cap-result 1034 0 0
sendmessage cap-result 1077 1 0
sendmessage cap-result 1075 1 0
sendmessage cap-result 1074 1 0
sendmessage cap-result 1076 1 0
do-events