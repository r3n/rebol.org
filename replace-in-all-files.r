REBOL [
    Title: "Replace-in-all-files"
    Date: 12-Jul-2001/10:09:36+2:00
    Version: 0.1.1
    File: %replace-in-all-files.r
    Author: "Oldes"
    Usage: {replace-in-all-files ["new/homes" "homes"]}
    Purpose: {To do recursive replace in all files in the directory}
    History: []
    Email: oldes@bigfoot.com
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

verbose: on  ; turn off for less info
replace-in-all-files: func [
    replacements    [block!]    "Block of replacements pairs"
    /path p         [file!]     "Starting directory"
    /local
     changed?   "If there was same replace in the file"
     data       "file content"
     do-replace "replacing function"
     total-files replaced-files "counters"
][
    total-files: 0
    replaced-files: 0 
    changed?: false
    do-replace: func[data][
        foreach [s t] replacements [
            if found? find data s [
                changed?: true
                replace/all head data s t
            ]
        ]
        data
    ]
    either path [path: p][
        path: to-file ask {Directory? }
        if empty? path [path: %./]
        if (last path) <> #"/" [append path #"/"]
    ]
    if not exists? path [print [path "does not exist"] halt]
    
    foreach file files: read path [
        either dir? path/:file [
            foreach newfile read path/:file [append files file/:newfile]
        ][
            total-files: total-files + 1
            changed?: false
            data: copy do-replace read/binary path/:file
            if changed? [
                replaced-files: replaced-files + 1
                if verbose [print join path/:file " ....changed"]
                write/binary path/:file data
            ]
        ]
    ]
    if verbose [print rejoin ["Replaced " replaced-files " from " total-files " files."]]
]

;replace-in-all-files ["new/homes" "homes"]