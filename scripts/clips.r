REBOL [
    Library: [
        level: 'intermediate
        platform: 'windows
        type: 'tool
        domain: 'ui
        tested-under: "View 1.3.2, Windows XP SP2"
        support: none
        license: 'bsd
        see-also: none
        ]

    Title: "Clips"
    Purpose: {
        Installs a tray icon (Windows only) and collects small
        text snippets.
    }
    Author: "Gabriele Santilli"
    EMail: giesse@rebol.it
    File: %clips.r
    License: {
Copyright (C) 2006  Gabriele Santilli

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

http://www.gnu.org/copyleft/gpl.html
    }
    Date: 28-Feb-2006
    Version: 1.2.0 ; majorv.minorv.status
                   ; status: 0: unfinished; 1: testing; 2: stable
    History: [
        11-Feb-2006 1.1.0 "History start"
        28-Feb-2006 1.2.0 "Added edit mode, comments"
    ]
]

;=== Globals
; holds all the text snippets
; loaded from %clips.txt, or defaults to example clips
; first block contains persistent clips (notes that you can add, edit, remove)
; second block contains the last 5 snippets from the system clipboard; older clips are
; removed to make room for new ones whenever you copy some text into the clipboard
; each clip is a block, first value is clip title, seconnd value is clip contents
clips: any [
    attempt [load %clips.txt]
    [
        [["Persistent clips" "Here you get persistent clips."]]
        [["Your clipboard" "Here you see the last five items from your clipboard."]]
    ]
]
; holds the keys to the clips from the tray menu
; (in the menu each item is identified by a word; this block maps that word to the actual clip block
; in the CLIPS block)
keys: []
; editing mode
editing?: no

;=== Sysport setup
system/ports/system/awake: func [port /local msg] [
    ; just in case we have more than one message queued
    while [msg: pick port 1] [
        ; we only handle messages from our systray menu
        if find/match msg [tray main menu] [
            ; name of the picked menu item
            msg: last msg
            switch/default msg [
                ; user choose "Add note..."
                save [
                    ; let user set note title and text
                    inform layout [
                        across text 70 right "Title:" title: field return
                        text 70 right "Note:" note: area any [attempt [read clipboard://] ""] return
                        pad 78 btn-enter "Add" [hide-popup]
                    ]
                    ; add the note to the list of persistent clips
                    insert/only tail clips/1 reduce [title/text note/text]
                    ; save changes to file
                    attempt [save %clips.txt clips]
                    ; recreate tray menu
                    set-tray
                ]
                ; user choose to switch to or out of edit mode
                edit [
                    ; toggle mode
                    editing?: not editing?
                    ; recreate menu (since the second item changes - should be optimized)
                    set-tray
                ]
                ; user choose "Quit"
                quit [
                    ; remove tray icon
                    set-modes port [tray: [remove main]]
                    quit
                ]
            ] [
                ; one of the clips has been selected?
                if msg: find keys msg [
                    ; the index of the word in the keys block is the index
                    ; of the clip in the clips block
                    msg: index? msg
                    either editing? [
                        ; edit mode: only first block can be edited
                        msg: at clips/1 msg
                        ; if at tail, maybe user selected a clip from the second block
                        ; otherwise edit it
                        if not tail? msg [
                            ; let the user edit or delete clip
                            inform layout [
                                across text 70 right "Title:" title: field msg/1/1 return
                                text 70 right "Note:" note: area msg/1/2 return
                                pad 78 btn red "Delete" [remove msg hide-popup] btn-enter "Ok" [hide-popup]
                            ]
                            ; save changes and recreate menu
                            attempt [save %clips.txt clips]
                            set-tray
                        ]
                    ] [
                        ; pick the clip
                        ; if msg is between 1 and length? clips/1, clip is from clips/1
                        ; if msg is between 1 + length? clips/1 and (length? clips/1) + (length? clips/2)
                        ; then clip is from clips/2
                        msg: any [pick clips/1 msg pick clips/2 msg - length? clips/1]
                        ; put the selected text in the clipboard
                        write clipboard:// msg/2
                    ]
                ]
            ]
        ]
    ]
    ; continue waiting
    false
]
; put the sysport in the wait list
insert tail system/ports/wait-list system/ports/system

;=== Functions
; function to create the systray menu
set-tray: has [menu w] [
    ; fixed menu items
    menu: compose [
        save: "Add note..."
        edit: (either editing? ["Normal mode"] ["Edit mode"])
        quit: "Quit"
        bar
    ]
    ; block of word keys to the clips
    keys: make block! add length? clips/1 length? clips/2
    ; add persistent clips to the menu
    foreach pclip first clips [
        ; make key word, clip1 for first clip, clip2 for second and so on
        w: to word! join "clip" index? tail keys
        append keys w
        ; add key and title to the menu block (e.g. clip1: "Title for clip 1")
        insert insert tail menu to set-word! w pclip/1
    ]
    ; bar to separate notes from clipboard history
    append menu 'bar
    ; add clipboard history to the menu
    foreach clip second clips [
        w: to word! join "clip" index? tail keys
        append keys w
        insert insert tail menu to set-word! w clip/1
    ]
    ; add systray icon with the menu
    set-modes system/ports/system compose/deep/only [
        tray: [
            add main [
                help: "Clips"
                menu: (menu)
            ]
        ]
    ]
]

;=== Main
; create systray icon with menu
set-tray
;alert "I will sit in your system tray and keep track of your clips."
; every 5 seconds, check the clipboard. if a new clip is present, add
; it to the clipboard history
forever [
    wait 5
    ; new clip present if 1) we get a string 2) it is not empty 3) it is not the same as the last clip in history
    if all [clip: attempt [read clipboard://] not empty? clip any [empty? clips/2 clip <> second last clips/2]] [
        ; add clip to the list (title generated from clip text)
        insert/only tail clips/2 reduce [trim/lines copy/part clip 20 clip]
        ; show only the last 5 items in the history
        ; note we are actually only moving the block position; on saving only
        ; values from this position onward are saved (since we are not using SAVE/ALL)
        ; and when generating the menu only these are considered
        clips/2: skip tail clips/2 -5
        ; save and recreate menu
        attempt [save %clips.txt clips]
        set-tray
    ]
]