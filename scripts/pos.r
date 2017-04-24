REBOL [
    title: "POINT OF SALE SYSTEM"
    date: 28-Feb-10
    file: %pos.r
    author:  Nick Antonaccio
    purpose: {
        This is a point of sale system (sales checkout, receipt printer, and data
        storage system) written using RebGUI.  It may help provide some basic
        insight into the workings of RebGUI.  Actually, the majority of this code
        manages user workflow - saving/retrieving receipts.  The RebGUI parts are
        simple and short.

        Note that the username and password info in the posp.db file should be
        created and read using a separate method, and encrypted.  The example
        posp.db file is created here as a demonstration.  Note also that the first
        field in the layout is designed to accept input from a keyboard wedge bar
        code scanner, with data in the format: item (space) booth (space) price
        (inserted [ENTER] key character).  Using this format, and the "focus" code
        which is executed after each scan entry, the user can continually scan
        multiple items into each ticket, without using the keyboard.  Manual
        keyboard-only entry is also supported.

        Taken from the tutorial at http:/re-bol.com
    }
]

write %posp.db {["username" "password"] ["username2" "password2"]} ; etc.
make-dir %./receipts/
write/append %./receipts/deleted.txt ""  ; create file if not exists

unless exists? %scheme_has_changed [
    write %ui.dat decompress #{
        789C9552CB92A3300CBCE72BBCDCA18084995A7E652A078115F08EB129592C33
        7FBFC24E32CC2387A5EC2A49ED6EB56C267845E5BB3FD8F32FF57250F2CD3060
        ABEAA629E23E95B1CAF8C6AD7A3A1571A5D28813E6D60CA32055752AAAE67751
        97CF3B5003BDB6EA5817CF821E9B8804067E484BE04F34BFB035EE4EACCB5371
        DD9FE044AD8E4FC5751FCE6AFA3E648FD6B62A51516F035731BE78B7B9AAEF49
        3EE2D5693A3CC02CCD63B8F5DB8CC464021A8CBB49066B3492901EB4879E8D77
        B92C74BC1D7CD1E467992DB0D8319CA28B41ABE53D42583D691566E31C521438
        7F9161E844241276780F84BCC117DF2F410E480E7BFCBDB7A697FA407E99F3CE
        BF493787568511919588E631DF5146131F602FFA1F8645B1437D35A2BA85D93B
        F5317A8C9810BF5DC240E6A1F0CF374CE4D790B31F507E45B9E10BD8801122D0
        6633DEEC5E3CFB8BA4C14176AF6D936540066CA6B2DE2F649094C35532361386
        EC0B270D18660B61CC355A78BFFD53ECBD6533DF8A655BCA4AD08A9D366E905E
        4C4B72B71AA7FDDA2AE71D1ECEFF004BE40F38A0030000
    }
]

do http://re-bol.com/rebgui.r

do login: [
    userpass: request-password
    if (length? userpass) < 2 [quit]
    posp-database: to-block read %posp.db
    logged-in: false
    foreach user posp-database [
        if (userpass/1 = user/1) and (userpass/2 = user/2) [
            logged-in: true
        ]
    ]
    either logged-in = true [] [
        alert "Incorrect Username/Password"
        do login
    ]
]
calculate-totals: does [
    tax: .06
    subtotal: 0
    foreach [item booth price] pos-table/data [
        subtotal: subtotal + to decimal! price
    ]
    set-text subtotal-f subtotal
    set-text tax-f (round/to (subtotal * tax) .01)
    set-text total-f (round/to (subtotal + (subtotal * tax)) .01)
    set-focus barcode
]
add-new-item: does [
    if ("" = copy f1/text) or ("" = copy f2/text) or (error? try [
        to-decimal copy f3/text
    ]) [
        alert trim/lines {You must enter a proper Item Description,
            Booth Number, and Price.}
        return
    ]
    pos-table/add-row/position reduce [
        copy f1/text copy f2/text copy f3/text
    ] 1
    calculate-totals
]
print-receipt: does [
    if empty? pos-table/data [
        alert "There's nothing to print." return
    ]
    html: copy rejoin [
        {<html><head><title>Receipt</title></head><body>
        <table width=40% border=0 cellpadding=0><tr><td>
        <h1>Business Name</h1>
        123 Road St.<br>
        City, State 98765<br>
        123-456-7890
        </td></tr></table><br><br>
        <center><table width=80% border=1 cellpadding=5>
        <tr>
        <td width=60%><strong>Item</strong></td>
        <td width=20%><strong>Booth</strong></td>
        <td width=20%><strong>Price</strong></td></tr>}
    ]    
    foreach [item booth price] pos-table/data [
        append html rejoin [
            {<tr><td width=60%>} item 
            {</td><td width=20%>} booth 
            {</td><td width=20%>} price {</td></tr>}
        ]
    ]
    append html rejoin [
        {<tr><td width=60%></td><td width=20%><strong>SUBTOTAL:
        </strong></td><td width=20%><strong>}
        copy subtotal-f/text 
        {</strong></td></tr>}
    ]
    append html rejoin [
        {<tr><td width=60%></td><td width=20%><strong>TAX:
        </strong></td><td width=20%><strong>}
        copy tax-f/text 
        {</strong></td></tr>}
    ]
    append html rejoin [
        {<tr><td width=60%></td><td width=20%><strong>TOTAL:
        </strong></td><td width=20%><strong>}
        copy total-f/text 
        {</strong></td></tr>}
    ]
    append html rejoin [
        {</table><br>Date: <strong>} now/date 
        {</strong>, Time: <strong>} now/time 
        {</strong>, Salesperson: } userpass/1
        {</center></body></html>}
    ]
    write/append to-file saved-receipt: rejoin [
        %./receipts/
        now/date "_"
        replace/all copy form now/time ":" "-"
        "+" userpass/1 
        ".html"
    ] html
    browse saved-receipt
]
save-receipt: does [
    if empty? pos-table/data [
        alert "There's nothing to save." return
    ]
    if allow-save = false [
        unless true = resaving: question trim/lines {
            This receipt has already been saved.  Save again?
        } [
            if true = question "Print another copy of the receipt?" [
                print-receipt
            ]
            return
        ]
    ] 
    if resaving = true [
        resave-file-to-delete: copy ""
        display/dialog "Delete" compose [
            text 150 (trim/lines {
                IMPORTANT - DO NOT MAKE A MISTAKE HERE!  
                Since you've made changes to an existing receipt,
                you MUST DELETE the original receipt.  The original
                receipt will be REPLACED by the new receipt (The
                original data will be saved in an audit history file,
                but will not appear in any future seaches or totals.)
                Please CAREFULLY choose the original receipt to DELETE:
            })
            return
            tl1: text-list 150 data [
                "I'm making changes to a NEW receipt that I JUST SAVED" 
                "I'm making changes to an OLD receipt that I've RELOADED"
            ] [
                resave-file-to-delete: tl1/selected
                hide-popup
            ]
            return
            button -1 "Cancel" [
                resave-file-to-delete: copy "" 
                hide-popup
            ]
        ]
        if resave-file-to-delete = "" [
            resaving: false
            return
        ]
        if resave-file-to-delete = trim/lines {
            I'm making changes to a NEW receipt that I JUST SAVED
        }  [
            the-file-to-delete: saved-file
        ]
        if resave-file-to-delete = trim/lines {
            I'm making changes to an OLD receipt that I've RELOADED
        } [
            the-file-to-delete: loaded-receipt
        ]
        if not question to-string the-file-to-delete [return]
        write %./receipts/deleted--backup.txt read %./receipts/deleted.txt
        write/append %./receipts/deleted.txt rejoin [
            newline newline newline
            to-string the-file-to-delete
            newline newline
            read the-file-to-delete
        ]
        delete the-file-to-delete
        alert "Original receipt has been deleted, and new receipt saved."
        resaving: false
    ]
    if true = question "Print receipt?" [print-receipt]
    saved-data: mold copy pos-table/data
    write/append to-file saved-file: copy rejoin [
        %./receipts/
        now/date "_"
        replace/all copy form now/time ":" "-"
        "+" userpass/1 
        ".txt"
    ] saved-data
    splash compose [
        size: 300x100
        color: sky
        text: (rejoin [{^/      *** SAVED ***^/^/      } saved-file {^/}])
        font: ctx-rebgui/widgets/default-font
    ]
    wait 1
    unview
    allow-save: false
    if true = question "Clear and begin new receipt?" [clear-new]
]
load-receipt: does [
    if error? try [
        loaded-receipt: to-file request-file/file/filter %./receipts/
            ".txt" "*.txt"
    ] [
        alert "Error selecting file"
        return
    ]
    if find form loaded-receipt "deleted" [
        alert "Improper file selection" 
        return
    ]
    if error? try [loaded-receipt-data: load loaded-receipt] [
        alert "Error loading data"
        return
    ]
    insert clear pos-table/data loaded-receipt-data
    pos-table/redraw
    calculate-totals
    allow-save: false
]
search-receipts: does [
    search-word: copy request-value/title "Search word:" "Search"
    ; if search-word = none [return]
    found-files: copy []
    foreach file read %./receipts/ [
        if find (read join %./receipts/ file) search-word [
            if (%.txt = suffix? file) and (file <> %deleted.txt) [
                append found-files file
            ]
        ]
    ]
    if empty? found-files [alert "None found" return]
    found-file: request-list "Pick a file to open" found-files
    if found-file = none [return]
    insert clear pos-table/data (
        load loaded-receipt: copy to-file join %./receipts/ found-file
    )
    pos-table/redraw
    calculate-totals
    allow-save: false
]
clear-new: does [
    if allow-save = true [
        unless (true = question "Erase without saving?") [return]
    ]
    foreach item [barcode f1 f2 f3 subtotal-f tax-f total-f] [
        do rejoin [{clear } item {/text show } item]
    ]
    clear head pos-table/data
    pos-table/redraw
    allow-save: true
]
change-appearance: does [
    request-ui
    if true = question "Restart now with new scheme?" [
        if allow-save = true [
            if false = question "Quit without saving?" [return]
        ]
        write %scheme_has_changed ""
        launch %pos.r  ; EDIT
        quit
    ]
]
title-text: "Point of Sale System"
if system/version/4 = 3 [
    user32.dll: load/library %user32.dll
    get-tb-focus: make routine! [return: [int]] user32.dll "GetFocus"
    set-caption: make routine! [
        hwnd [int] 
        a [string!]  
        return: [int]
    ] user32.dll "SetWindowTextA"
    show-old: :show
    show: func [face] [
        show-old [face]
        hwnd: get-tb-focus
        set-caption hwnd title-text
    ]
]

allow-save: true
resaving: false
saved-file: ""
loaded-receipt: ""

screen-size: system/view/screen-face/size
cell-width: to-integer (screen-size/1) / (ctx-rebgui/sizes/cell)
cell-height: to-integer (screen-size/2) / (ctx-rebgui/sizes/cell)
table-size: as-pair cell-width (to-integer cell-height / 2.5)
current-margin: ctx-rebgui/sizes/margin
top-left: as-pair negate current-margin negate current-margin

display/maximize/close "POS" [
    at top-left #L main-menu: menu data [
        "File" [
            "     Print      " [print-receipt]
            "     Save       " [save-receipt]
            "     Load       " [load-receipt]
            "     Search     " [search-receipts]
        ]
        "Options" [
            "     Appearance     " [change-appearance]
        ] 
        "About" [
            "     Info     " [
                alert trim/lines {
                    Point of Sale System. 
                    Copyright © 2010 Nick Antonaccio. 
                    All rights reserved.
                }
            ]
        ]
    ]
    return
    barcode: field #LW tip "Bar Code" [
        parts: parse/all copy barcode/text " "
        set-text f1 parts/1
        set-text f2 parts/2
        set-text f3 parts/3
        clear barcode/text
        add-new-item
    ]
    return
    f1: field tip "Item" 
    f2: field tip "Booth" 
    f3: field tip "Price (do NOT include '$' sign)" [
        add-new-item 
        set-focus add-button
    ]
    add-button: button -1 "Add Item" [
        add-new-item 
        set-focus add-button
    ]
    button -1 #OX "Delete Selected Item" [
        remove/part find pos-table/data pos-table/selected 3
        pos-table/redraw
        calculate-totals
    ]
    return
    pos-table: table (table-size) #LWH options [
        "Description" center .6
        "Booth" center .2
        "Price" center .2
    ] data []
    reverse
    panel sky #XY data [
        after 2
        text 20 "Subtotal:" subtotal-f: field 
        text 20 "     Tax:" tax-f: field
        text 20 "   TOTAL:" total-f: field
    ]
    reverse
    button -1 #XY "Lock" [do login]
    button -1 #XY "New" [clear-new]
    button -1 #XY "SAVE and PRINT" [save-receipt]
    do [set-focus barcode]
] [question "Really Close?"]

do-events
