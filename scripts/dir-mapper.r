REBOL [
    Title: "Directory Mapper"
    Date: 18-Jul-2001/10:09:09+2:00
    Version: 1.0.5
    File: %dir-mapper.r
    Author: "Oldes and Stephane Bagnier"
    Usage: "dir-mapper/map %/d/rebol/"
    Purpose: {Recursively builds a dir-structure map of the directory
with file/dir informations as size and dates
}
    Comment: {
^-dir-map-structure: [
^-^-%dir/ [creation-date modification-date] [
^-^-^-%file [size creation-date access-date modification-date]
^-^-^-%file [size creation-date access-date modification-date]
^-^-^-%dir/ [creation-date modification-date] [
^-^-^-^-%file [size creation-date access-date modification-date]
^-^-^-]
^-^-]
^-]
^-
^-The size or date can be 'none in some cases!
^-
^-This script works with recursive dir-map structure that is not so good for large and deep directories. So I'll probably do better non-recursive structure soon.
^-}
    History: [
    1.0.5 18-Jul-2001 {oldes: fixed math owerflow bug in counting 'total-size} 
    1.0.4 17-Jul-2001 "oldes: starting dir also included in the map" 
    1.0.3 13-Jul-2001 {oldes: encode filename function - Rebol seems to have problem with saving/loading block of files containing extended and special chars (as #"%" or #"@") :(} 
    1.0.1 12-Jul-2001 {oldes: access-date is not mapped for dirs (they are always accessed while mapping so this time is not useful:)} 
    1.0.0 12-Jul-2001 "oldes: Modified dir-tree + dir-mapper object" 
    0.0.0 20-Jun-1999 "Stephan: %dir-tree.r script"
]
    Email: oldes@bigfoot.com
    mail: [oldes@bigfoot.com bagnier@physique.ens.fr]
    Need: 2.5
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: [file-handling DB] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

dir-mapper: make object! [
    total-dirs: 0
    total-files: 0
    total-size-tmp: copy []
    total-size: make decimal! 0
    encode-filename: func [
        {Rebol has problems with special chars in the file name!}
        filename [file! string!] "filename to encode"
        /local new-data
    ][
        filename: to-string filename
        new-data: make string! ""
        normal-char: charset [#"A" - #"Z" #"a" - #"z" #"." #"*" #"-" #"_" #"/" #"0" - #"9"]
        forall filename [
            append new-data either find normal-char first filename [
                first filename
            ][
                rejoin ["%" to-string skip tail (to-hex to-integer first filename) -2]
            ]
        ]
        to-file new-data
    ]

    Get-date: func[item [file!] type [word!] /local date][
        either error? try [date: get-modes item type][none][date]
    ]
    Get-item-info: func [item /local s is-dir][
        info: copy []
        if not is-dir: dir? item [
            insert tail info s: size? item
            either none? s [
                print ["WARNING: size = none for" mold item]
            ][
                total-size: total-size + s
            ]
        ]
        insert tail info Get-date item 'creation-date
        if not is-dir [insert tail info Get-date item 'access-date]
        insert tail info Get-date item 'modification-date
        info
    ]
    dir-tree: func [
        current-path [file! url!] "directory to explore"
        /inner
        tree [block!] "useful to avoid stack overflow"
        /depth "recursion depth, 1 for current level, -1 for infinite"
        depth-arg [integer!]
        /local
        current-list
        sub-tree
        item
        pad
    ][
        if all [not inner not block? tree] [tree: copy []]
        depth-arg: either all [depth integer? depth-arg] [depth-arg - 1][-1]
        current-list: read current-path
        if not none? current-list [
            foreach item current-list [
                insert tail tree reduce [
                    encode-filename item
                    Get-item-info current-path/:item
                ]
                total-files: total-files + 1
                if all [dir? current-path/:item not-equal? depth-arg 0] [
                    pad: copy ""
                    prin head insert/dup pad "-" (-1 - depth-arg)
                    probe current-path/:item
                    total-dirs: total-dirs + 1
                    sub-tree: copy []
                    dir-tree/inner/depth current-path/:item sub-tree depth-arg
                    insert/only tail tree sub-tree
                ]
            ]
        ]
        return tree
    ]
    map: func[current-path /local tree][
        total-dirs: 0
        total-files: 0
        total-size: make decimal! 0
        total-size-tmp: copy []
        tree: copy []
        insert tail tree reduce [
            encode-filename current-path
            Get-item-info current-path
        ]
        sub-tree: copy []
        sub-tree: dir-tree/inner/depth current-path sub-tree -1
        insert/only tail tree sub-tree
        print reduce ["Found" total-files - total-dirs "files in" total-dirs "dirs = total size:" total-size "B"]
        tree
    ]
]

                                                                                                                                     