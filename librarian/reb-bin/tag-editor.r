REBOL [
    Title: "REBOL Librarian Tag Editor Module"
    Version: 0.1.0
    Date: 17-feb-2003
    File: %tag-editor.r
    Type: 'link-app
    Author: "REBOL Library Team"
    Purpose: "Edit tags that classify library entries."
    Category: [Util]
    ToDo: {
        - make resistant to errors caused by scripts with poorly formed headers.
    }
    History: [
        0.1.1 {"edit-tags" press -> window to front. 'to-front os-dependent}
        0.1.0 [17-feb-2003 Gregg
            Modified to integrate with new librarian code base.
            Everything here lives in a TAG-EDITOR context now.
            Whacked and hacked quite a bit of stuff. Needs lots of cleaning.
        ]
        0.0.8 "better tag-list"
        0.0.7 "selects by new tags"
        0.0.6 "tag-set-editor for library-fields"
        0.0.5.2 "loads of additional fields"
        0.0.5.1 "playing with layout, vn"

        0.0.2 [20-nov-2002 "GSI"
            {Added para setting to pop-up view area so it resets to top on
            each new view.}
        ]
        0.0.3 [20-nov-2002 "GSI"
            {Added scroll bars to pop up view area.}
        ]
        0.0.4 [28-Nov-2002 "Anton"
            {adding a new function publish-script for the "Publish" button.}
        ]
        0.0.5 [4-Dec-2002 "Anton"
            {certify-script can now load a file with *only* a rebol header and no code following it}
        ]
    ]
]


tag-editor: context [

    ;-- Fileset name and location:
    all-tags: [
        level [beginner intermediate advanced]
        platform [all windows win linux mac unix *nix solaris amiga be]
        type [
            Demo Tool Game
            Reference How-to FAQ Article Tutorial Idiom
            one-liner function module protocol dialect
        ]
        domain [
            math financial scientific
            UI user-interface GUI VID
            graphics sound animation
            web http ftp cgi tcp email ldc ssl other-net
            protocol scheme
            DB database odbc mysql sql
            files file-handling
            text text-processing markup html xml parse dialects
            printing AI visualization encryption compression
            x-file win-api external-library shell
            patch
            dead broken
        ]
        tested-under []
        support []
        license [public-domain BSD GPL LGPL MIT IBMPL MPL W3C Artistic Sleepycat]
    ]

    sort all-tags/domain

    ;-- Tags Editor  -----------------------------------------------------------

    ; Volker - How does this differ from the native CONSTRUCT? Can you
    ; write a little interface note for this and my-load-header? Tks -Gregg
    my-construct: func [block /base object /local ctx dat word data] [
        ctx: copy []
        dat: copy []
        parse block [any [
                set word set-word! set data any-type! (
                    append ctx word
                    repend dat [to-word word data]
                )
                | skip
            ]]
        object: any [object object!]
        ctx: make object append ctx none
        foreach [word data] dat [
            set in ctx word either 'none = data [none] [data]
        ]
        ctx
    ]

    my-load-header: func [loadable /local block] [
        block: load/all loadable
        if parse block ['rebol set block block! to end] [
            my-construct/base block system/standard/script
        ]
    ]

    ; Renamed from obj2blk - Gregg
    obj-spec: func [object [object!] /molded] [
        either molded [first load/all find mold object "["] [third object]
    ]

    ; This needs a better name!
    pingpong: func [
        all-tags [block!]
        selected [block! string!]
        title'
        /string
        /local f-unselected f-selected unselected select-tag unselect-tag
    ] [
        ;bind functions here..
        select-tag: func [string /local new] [
            insert f-selected/data string
            new: intersect all-tags f-selected/data
            insert clear f-selected/data new
            if 2 <= length? f-selected/data [remove find f-selected/data 'none]
            ;probe mold/all f-selected/data
            show [f-selected f-unselected]
        ]
        unselect-tag: func [string] [
            remove find f-selected/data string
            if empty? f-selected/data [insert f-selected/data 'none]
            show [f-selected f-unselected]
        ]
        if string [selected: to-block selected]
        ;unselected: exclude all-tags selected
        unselected: all-tags ;replace name..
        backup: copy selected
        tl-size: 150x250
        inform layout [
            title title' white black
            guide
            label "unselected"
            f-unselected: text-list data unselected tl-size with [
                append init [
                    iter/feel/redraw: func [f a i] [
                        f/color: either find picked f/text [svvc/field-select] [slf/color]
                        f/color: either find f-selected/data f/text [green] [f/color]
                    ]
                ]
            ]
            return
            pad 0x200
            arrow right [select-tag first f-unselected/picked]
            arrow left [unselect-tag first f-selected/picked]
            return
            label "selected"
            f-selected: text-list data selected tl-size
            at 0x1 * f-unselected/size + f-unselected/offset + 0x20 guide
            button "ok" [hide-popup] return
            button "cancel" [selected: backup hide-popup]
        ]
        either string [form selected] [selected]
    ]

    edit-list-tags: func [
        {Displays a UI for editing tags you set from lists of choice.
        Right now it's just a wrapper over pingpong.}
        field "The header field we're editing"
        face "The face to get and set the values against"
        /choices blk
        /value val "The starting value, if a face isn't specified"
        /local result
    ] [
        if not choices [blk: all-tags/:field]
        result: pingpong/string blk either value [val] [face/text] form field
        if face [face/text: result show face]
        result
    ]

    ;-- User Interface -----------------------------------------------------------

    ;stylize/master [
    ;    lab: text 100x24 bold white black font-size 11 right middle
    ;]

    main: layout [
        across origin 10 ;origin 0x0 space 0x0 backcolor 80.120.110
        ;backcolor colors/4  ; this is a global color

        ;p1: lab left 156 "Tags:" return
        style lab text 100x24 bold white coal font-size 11 right middle

        guide space 0x4
        ;---
        ;at 1x0 * f-title/size + f-title/offset + 5x0 guide
        h3 "Standard Header Fields" return
        lab "Title" f-title: field "" return
        lab "File" f-file: field return
        lab "Version" f-version: field return
        lab "Date" f-date: field return
        lab "Author" f-author: field return
        ;lab "Category:" f-cat: info return

        f-libspec: h3 "Library Header Fields" return
        ; level platform type domain license: editable
        lab "Level" [edit-list-tags 'level f-level] f-level: info return
        lab "Platform" [edit-list-tags 'platform f-platform] f-platform: info return
        lab "Type" [edit-list-tags 'type f-type] f-type: info return
        lab "Domain" [edit-list-tags 'domain f-domain] f-domain: info return
        lab "Tested Under" f-tested-under: info return
        lab "Support" f-support: info return
        lab "License" [edit-list-tags 'license f-license] f-license: info return
        bottom: at

        space 0

        ;at f-level/size/x * 1x0 + f-level/offset pad 5x0 guide
        at f-title/size/x * 1x0 + f-title/offset pad 5x0 guide

        lab 300 center "Purpose" return
        f-purpose: area 300x112 wrap return
        pad 200x4
        space 4x4
        ; view-item is a function in the main librarian script.
        button "View Script" [view-item current-script]
        ;btn 72 "Publish" [publish-script selected-file]
        ;btn 72 "Contact" [alert "Contact author. Not implemented"]
        ;btn 72 "Delete" [alert "Delete from library. Not implemented."]
        ;return

        at (bottom + 400x0)
        button "OK" [save-script unview/only main]
        button "Cancel" [unview/only main]
        ;button "Help" [alert "TBD"]
    ]

    to-front: func [main] [
        switch/default fourth system/version [
            ; linux/kde 'activate jumps..
            4 [
                unview/only main
                view/new/title main "Tag Editor"
                'done
            ]
        ] [
            view/new/title main "Tag Editor"
            main/changes: 'activate
            show main
            'ok
        ]

    ]
    prepare-launch: func [file /l dir sbox] [
        set [dir file] split-path clean-path file
        make-dir/deep clean-path sbox: %sandbox/
        write/binary sbox/:file read/binary dir/:file
        save/header %launch-tagged.r compose/deep [
            secure [shell ask library ask file ask (sbox) allow]
            probe secure query
            do system/options/script: (sbox/:file)
            if not empty? system/view/screen-face/pane[do-events]
        ] compose [title: "start file in tag-editor" file: (file)
            type: 'link-app]
    ]
    edit-tags: func [file /with face] [
        prepare-launch file
        load-script file
        if with [
            main/color: face/color
            center-face/with main face
        ]
        to-front main
    ]

    ;-- Script Certification -----------------------------------------------------
    ;
    ;   Determines if a script has what it needs to be a valid library script.
    ;   This function (or something similar) should become our standard method
    ;   for checking script headers.
    ;   (but it checks new headers a bit lazy now, -volker)

    certify-script: func [file /local msg
        ;data header result
    ] [
        all [; verify the script and header
            msg: "Not a .r file"
            %.r = find/last file %.r
            msg: "Cannot read header"
            script? file
            not error? try [data: read file]
            not error? try [header: my-load-header data]
            ;not error? try [header: load/header data if block? header [header: first header]]
            ;print ["type? my-load-header data =" type? my-load-header data]
            ;print ["load/header data =" mold my-load-header data]
            ;probe type? header
            result: true
            foreach item [title library] [
                if not all [
                    in header item
                    series? header/:item
                    not empty? header/:item
                ] [
                    msg: reform ["Missing or invalid" item "field"]
                    result: false
                ]
                result
            ]
            not if not all [in header 'purpose string? header/purpose] [
                ;print [file "is missing its purpose"]
                header/purpose: copy header/title
                none
            ]
            ;msg: join "Invalid category " mold grp: exclude header/category script-tags
            ;empty? grp
            msg: "Bad date"
            in header 'date
            date? header/date
            header/date > 1-Jan-1997
            header/date < (now + 2)
            msg: "Filename does not match"
            header/file = second split-path file
            msg: none
        ]
        reduce [msg header data]
    ]

    load-script: func [file /local result header] [
        result: certify-script file
        if result/1 [
            if not confirm rejoin [result/1 ":" file " Continue to load it?"] [exit]
        ]
        current-script: result/3
        current-file: file
        ;current-header: header: result/2
        header: result/2
        f-title/text: form header/title
        f-author/text: any [header/author "Anonymous"]
        f-date/text: either date? header/date [header/date] [now]
        f-version/text: either tuple? header/version [header/version] [1.0.0]
        f-file/text: second split-path file
        f-purpose/text: trim/lines any [header/purpose copy ""]
        ;f-cat/text: form header/category
        ;---
        libhdr: context header/library ;construct ..
        f-level/text: mold/only libhdr/level
        f-platform/text: mold/only libhdr/platform
        f-type/text: mold/only libhdr/type
        f-domain/text: mold/only libhdr/domain
        f-tested-under/text: mold/only libhdr/tested-under
        f-support/text: mold/only libhdr/support
        f-license/text: mold/only libhdr/license
        ;---
        show main
    ]

    save-script: func [/local hdr lib fac in-lib tag tags src] [
        ;    echo %echo.txt
        set [hdr src] load/next/all second load/next/all current-script
        ;hdr: my-construct/base hdr context[
        ; Title: Date: Version: File: Author: Purpose: none]
        hdr: my-construct hdr
        ;add new fields, keep order
        hdr': make context [Title: Date: Version: File: Author: Purpose: none] hdr
        hdr: make hdr hdr' ;old order back
        lib: my-construct hdr/library

        ; level platform type domain license: editable

        ; save fields
        foreach base [f-platform f-domain f-license f-level f-type] [
            fac: get base
            in-lib: in lib to-word next next to-string base
            ;*sigh* load/all inserts newline.
            ;hack: extract load block 1 -> no newline :)
            tags: load/all fac/text
            either [none] = tags [tags: none] [
                either 1 = length? tags
                [tags: to-lit-word first tags] [tags: extract tags 1]
            ]
            set in-lib tags
        ]
        ;if not do [
        if not attempt [
            ;strings, should work allways
            hdr/title: f-title/text
            hdr/author: f-author/text
            hdr/purpose: f-purpose/text
            ;converted types
            hdr/file: load mold to-file f-file/text ;with reloadable-check
            hdr/version: to-tuple f-version/text
            hdr/date: to-date f-date/text
        ] [alert "could not store general data completely"]
        hdr/library: obj-spec/molded lib
        src: rejoin [
            "REBOL " find mold/only hdr "[" src
        ]
        either strict-equal? src current-script [alert "no changes"] [
            inform layout [
                title "would save" across
                h2 mold current-file text "changed <-> original"
                return
                button "save really" [
                    write current-file src hide-popup ;rebuild-index
                    ;------------------------------------------------
                    ; Use functions in support library to work with index.
                    update-index-entry 'file second split-path current-file hdr
                    save-index
                    ;------------------------------------------------
                ]
                button "cancel" [hide-popup]
                return
                tl: area src 300x400 para []
                sl: slider 16x400 [
                    scroll-para tl sl tr/para/scroll: tl/para/scroll show tr
                ]
                tr: area current-script 300x400 para []
            ]
        ]
    ]


]
