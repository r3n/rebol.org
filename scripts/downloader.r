REBOL [
    Title: "Downloader"
    Date: 23-May-2002/0:33:57+2:00
    Version: 0.2.2
    File: %downloader.r
    Author: "oldes"
    Purpose: {To download multiple remote files and show the progress}
    Email: oliva.david@seznam.cz
    library: [
        level: none 
        platform: none 
        type: 'tool 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
downloader: func [
    "Download multiple files from the net. Show progress. Return block of file sizes."
    urls [block!]   "Block of files to download"
    title-str
    /to dir [file!] "If the target file should be placed in other directory then in public/"
    /log log-file   [file! url!]    "File where informations about downloaded files is written"
    /update "Force update"
    /local lo f tmp msg logport upd-func onclose sizes
][
   lo: layout/size [
        backdrop black
        origin 1x1
        box 155x38 170.185.165
        at 160x2 box 35x35 black
        at 157x0 box 1x42 115.150.132
        at 1x1 label 155 center title-str 
        at 3x23 prog: progress  151x14 150.165.145 edge [size: 1x2 color: black] with [
            colors: [248.172.3 217.51.51]
        ]
        at 3x23 stat: h4 151x14 font [size: 9] center middle
    ] 200x42 
    lo/edge: make lo/edge [size: 1x1 color: 115.150.132]
    if log [
        onclose: func [f e][if e/type = 'close [close logport quit] e]
        insert-event-func :onclose
        msg: func[t][append logport t]
        logport: open/new/write log-file
        msg tmp: rejoin ["##[DOWNLOAD started: " now "]##^/"]
        msg head insert/dup "" "#" (length? tmp) - 1
        if to [ msg rejoin ["^/##[TARGET: " dir "]##" ] ]
    ]
    view/new/options center-face lo [no-title no-border]
    upd-func: func [total bytes][
        prog/data: bytes / (max 1 total)
        show prog
        tmp: total
        true
    ]
    sizes: make block! []
    foreach url reduce urls [
        probe url
        f: decode-url url
        stat/text: f/target
        show stat
        tmp: 0
        either to [
            if none? f/path [f/path: ""]
            targ: rejoin [dirize dir f/host "/" f/path]
            make-dir/deep targ
            either update [
                read-thru/progress/update/to url :upd-func join targ f/target
            ][  read-thru/progress/to url :upd-func join targ f/target]
        ][  either update [
                read-thru/progress/update url :upd-func
            ][  read-thru/progress url :upd-func ]
        ]
        if log [msg rejoin [newline now/time/precise tab url tab tmp]]
        append sizes tmp
    ]
    if log [
        msg "^/##[END of download]##"
        close logport
        remove-event-func :onclose
    ]
    unview/only lo
    sizes
]
                                                                             