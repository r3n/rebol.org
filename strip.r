REBOL [
    File: %strip.r
    Date: 16-6-2006
    Version: 1.0.0
    Title: "StRIP" 
    Purpose: "REBOL File packer"
    Author: "Boleslav Brezovsky, based on rip.r by Carl Sassenrath/Cal Dixon"
    History: [
        1.0.0 16-6-2006 BB "first public release"
    ]
    library: [
        level: 'intermediate
        platform: 'all
        type: [tutorial tool]
        domain: [files shell gui]
        tested-under: 'winxp
        support: rebolek@gmail.com
        license: 'bsd
        see-also: %rip.r
    ]
] 
ctx-strip: context [
    gui?: yes 
    list-view?: no 
    if list-view? [
        do-thru http://www.fm.vslib.cz/~ladislav/rebol/include.r 
        read-thru/to http://www.hmkdesign.dk/rebol/list-view/list-view.r %list-view.r 
        include %list-view.r
    ] 
    archive: make binary! 32000 
    file-list: copy [] 
    get-files: func [path /verbose /local files un] [
        result: copy [] 
        files: read path 
        foreach file files [
            either dir? join path file [
                repend file-list [path/:file 'DIR] 
                either verbose [get-files/verbose join path file] [get-files join path file]
            ] [
                if all [verbose not gui?] [prin [tab join path file " "]] 
                data: read/binary join path file 
                un: length? data 
                if all [verbose not gui?] [prin [un " -> "]] 
                data: compress data 
                if all [verbose not gui?] [print length? data] 
                append archive data 
                if all [verbose gui?] [
                    either list-view? [
                        repend/only ~lv/data [path/:file un length? data] 
                        ~lv/update 
                        ~lv/last-cnt
                    ] [
                        append ~lv/data rejoin ["" path/:file "   (" un " --> " length? data ")"] 
                        ~lv/sld/redrag 20 / max 20 length? ~lv/data 
                        ~lv/sld/data: 1.0 
                        ~lv/sn: max 0 -20 + length? ~lv/data 
                        show ~lv
                    ]
                ] 
                repend file-list [join path file length? data]
            ]
        ]
    ] 
    draw-font: make face/font [size: 36] 
    smal-font: make face/font [size: 24] 
    lay: layout compose [
        origin 5 
        across 
        space 0 
        backdrop effect [gradient 0x1 255.255.255 180.180.180 grid 0x5 240.240.240] 
        style button button edge [size: 1x1] 180.180.180 font [size: 10 colors: [0.0.0 200.0.0] shadow: 1x0] 100x20 
        style field field edge [size: 1x1] 400x20 
        box 500x50 effect [draw [pen black fill-pen 239.51.42 font draw-font text 100x0 "StRIP" vectorial font smal-font text 200x15 "REBOL packer" vectorial]] 
        return 
        button "Select directory" [
            use 'file [
                file: request-dir 
                if not none? file [~f-dir/text: file] 
                show ~f-dir
            ]
        ] 
        ~f-dir: field (to string! what-dir) 
        return 
        button "Output file" [
            use 'filename [
                filename: request-file/save/only 
                if not none? filename [
                    if not equal? "rip" last parse filename "." [append filename ".rip"] 
                    ~f-file/text: filename 
                    show ~f-file
                ]
            ]
        ] 
        ~f-file: field (to string! join what-dir %archive.rip) 
        return 
        button 500x40 "PACK" font-size 14 [strip/verbose to file! ~f-dir/text to file! ~f-file/text] 
        return 
        ~lv: (
            either list-view? [[
                    list-view 500x300 with [
                        widths: [350 75 75] 
                        data-columns: [Files Orig-size Comp-size]
                    ]
                ]] [[
                    text-list 500x303
                ]]
        ) 
        return 
        text 500x13 font-size 9 {v 1.0.0 (c)2006 ReBolek based on RIP.r (c)2000 Carl Sassenrath/Cal Dixon.} black 180.180.180
    ] 
    set 'strip func [
        "Pack files" 
        path "Directory to pack" 
        filename "Output file" 
        /verbose "Turn on verbose output"
    ] [
        clear ~lv/data 
        if list-view? [~lv/update] 
        file-list: copy [] 
        if all [verbose not gui?] [print "Archiving:"] 
        either verbose [get-files/verbose path] [get-files path] 
        if verbose [
            case [(gui? list-view?) (
                    repend/only ~lv/data ["" "" ""] 
                    repend/only ~lv/data ["Total size:" "" length? archive] 
                    repend/only ~lv/data ["Checksum:" "" checksum archive] 
                    ~lv/update 
                    ~lv/max-cnt
                ) (gui? and not list-view?) (
                    append ~lv/data "" 
                    append ~lv/data rejoin ["Total size: " length? archive] 
                    append ~lv/data rejoin ["Checksum: " checksum archive] 
                    show ~lv
                ) (not gui?) (print [newline "Total size:" length? archive "Checksum:" checksum archive newline])]
        ] 
        header: mold compose/deep [
            REBOL [
                Title: "REBOL Self-extracting Binary Archive (RIP)" 
                Date: (now) 
                File: (filename) 
                Note: (reform ["To extract, type REBOL" filename "or run REBOL and type: do" filename])
            ] 
            path: (path) 
            verbose: (verbose) 
            files: (reduce [file-list]) 
            check: (checksum archive) 
            if not exists? path [make-dir path] 
            archive: (as-string archive) 
            if check <> checksum archive [print ["Checksum failed" check checksum archive] halt] 
            foreach [file len] files [
                if verbose [print [tab file]] 
                either len = 'DIR [
                    if not exists? file [make-dir/deep file]
                ] [
                    data: decompress copy/part as-binary archive len 
                    archive: skip archive len 
                    write/binary file data
                ]
            ]
        ] 
        write/binary filename header
    ] 
    set 'strip-gui does [
        gui?: yes 
        view center-face lay
    ]
] 
if ctx-strip/gui? [strip-gui]