;;
;; This is a multi-script file, so that db.r could tag along
;;   I don't know if you know this, but no one bends it like REBOL
;;
[
REBOL [
    Title: "RebGUI and RebDB Sample"
    File: %rebdbgui.r
    Author: "Brian Tiffin"
    Date: 02-Jul-2007
    Version: 0.9.0
    Home: http://www.dobeash.com
    Rights: "Copyright (c) 2007 Brian Tiffin"
    Usage: "do-thru http://www.rebol.org/library/scripts/rebdbgui.r"
    Purpose: "A quick demonstration of RebGUI with RebDB"
    Comment: "This script litters the global namespace without regard"
    Library: [
        level: 'advanced
        platform: 'all
        type: [tutorial how-to]
        domain: [gui db]
        tested-under: [view 1.3.2.4.2 Debian GNU/Linux 4.0]
        support: http://www.rebol.org
        license: 'MIT
        see-also: "http://www.opensource.org/licenses/index.html"
    ]
]

;; Load RebGUI and RebDB...
;;   RebGUI loaded through the sandbox
;;   RebDB included with source code...
unless value? 'ctx-rebgui [
    do-thru http://www.dobeash.com/RebGUI/rebgui.r
    do decompress first select load/all system/script/header/file 'rebdb
    ;; Add a 'data' widget
    append-widget [
        edit-field: make field [
            init: does [text: do data]
        ]
    ]
    ;; This next widget is an experiment...
    ;;   ...it can get VERY expensive...
    ;;   Don't use this for editable fields, the data redraw will get you.
    append-widget [
        data-field: make field [
            edge: make default-edge [
                size: 0x0
            ]
            feel: make default-feel [
                redraw: func [face act pos] [
                    do select [
                        draw [face/text: do face/data]
                        show [face/text: do face/data]
                        hide []
                    ] act
                ]
                engage: none
            ]
        ]
    ]
]

;; Gets in the way of testing...
;; it helps for data recovery and error reporting in full blown apps...
all [exists? %rebgui.log  question "Delete rebgui.log? "  attempt [delete %rebgui.log]]
all [exists? %replay.bak  question "Delete replay.bak? "  attempt [delete %replay.bak]]
all [exists? %testdb.log  question "Delete testdb.log? "  attempt [delete %testdb.log]]

;; Create a database if needed
if not exists? %testdb.ctl [
    either question "Create testdb? " [
        db-create testdb [id name age picture]
        db-insert testdb reduce [1 copy "Brian" copy "43" %brian.png]
        db-insert testdb reduce ['next copy "Bruce" copy "40" %bruce.png]
        db-insert testdb reduce ['next copy "REBOL" to string! now/year - 1997 "logo.gif"]
        db-commit testdb
    ][
        alert "I'm going home then"
        quit
    ]
]
;;
;; Get-data function
;;
get-data: func [key [integer!] field [block!] /local value] [
    either error? value: try [
        db-select/where :field testdb compose [id = (key)]
    ][
        reform ["Field" field key "**error**"]
    ][
        either empty? value [copy ""] [copy first value]
    ]
]

;;
;; Save data function
;;
put-data: func [face key [integer!] 'field [word!] /nocommit /local ret] [
    either error? ret: try [
        db-update/where testdb :field face/text compose [id = (key)]
    ][
        ret: mold disarm ret
        alert reform ["Error writing" field key newline copy/part ret 200]
    ][
        unless nocommit [db-commit testdb]
        ;; This would not go here in a production application
        insert clear thetable/data (db-select * testdb)
        thetable/redraw
        ;; Yeah, cut this thetable/data upate part for a production app
        ret
    ]
]
;;
;; Put up the data form
;;
display "RebGUI with RebDB Sample" [
    label "Testing"
    button 25 "Close" [unview]
    button 25 "Explain" [
        display "Explanation" [
            label "Explanation" button 25 "Close" [unview]
            return
            text {
This little database shows off RebDB usage within RebGUI.

All the fields use a special widget that retrieves data from the database on init.

The first field's name is only saved if you press the update button
The first age is saved if you trigger the action block, by hitting enter.

The second name is always Bruce and uses an experimental overly expensive widget
that continously retrieves data on every gui redraw.

The second age is saved but not committed on hitting the Replay Age button,
and this will give you a chance to see RebDB database replays in action.
Change the second age, hit the button, close the app and then restart
to see this powerful feature.  Any other changes will commit, so close the
and restart right after the Replay Age change.

The third name and age fields are updated to the database as you type.

The fourth field should be empty...it does not exist in the sample database.
The fourth name field is filled with data selected from the Database List table.

*Use the Source Code button to decompress and save the included dbinc.r*

**Except for the logo, the picture db field is NOT used**
}
            return bar #L return
            text text-color brick {
By the way...this script is just to show off features.
Performance is poor, very poor...so very, very ineffecient.}
        ]
    ]
    button 25 "Source Code" [
        if question "Write dbinc.r? " [
            write/binary %dbinc.r decompress first select load/all system/script/header/file 'rebdb
        ]
    ]
    return
    ;; Only save name if the update button is pressed"
    label 20 "Name:"
    namefield: edit-field data [get-data 1 [name]]
    ;; Save age on pressing return
    label "Age:"
    edit-field 10 data [get-data 1 [age]] [put-data face 1 age]
    button 25 "Update Name" [put-data namefield 1 name]
    return
    ;; This field is read-only and should be "Bruce"
    ;;  Plus the age field is not commited, so a close right after
    ;;  an Update Age will kick database replay
    label 20 "Bruce"
    data-field data [get-data 2 [name]]
    label "Age:"
    agefield: edit-field 10 data [get-data 2 [age]]
    button 25 "Replay Age" [put-data/nocommit agefield 2 age]
    return
    ;; This field should auto-save after an edit"
    label 20 "Third"
    edit-field data [get-data 3 [name]] on-edit [put-data face 3 name] edge [color: 192.32.32]
    label "Age:"
    edit-field 10 data [get-data 3 [age]] on-edit [put-data face 3 age] edge [color: 192.32.32]
    image (get load get-data 3 [picture])
    return
    ;; This field shouldn't exist"
    label 20 "No Fourth"
    invalid-field: edit-field data [get-data 4 [name]]
    return
    label "Database List"
    return
    ;; Plog selected name into the invalid fourth field...
    thetable: table 80x20 options [
        "Id" right .2 "Name" left .3 "Age" right .2 "Picture" right .3
    ] on-click [
        set-text invalid-field second face/selected
    ] data (db-select * testdb)
] do-events
] ;; end rebdbgui.r
rebdb [
64#{
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
}]