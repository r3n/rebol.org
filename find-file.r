REBOL [
    Title: "Find a file in directories / folders"
    Date: 20-Jun-2002
    Name: 'find-file
    File: %find-file.r
    Version: 1.0.0
    Author: "Carl Sassenrath"
    Purpose: "Search all files for ones that contain a given string."
    Note: {
        Seems like this should be in the library somewhere, but
        I could not find it, and I use it a lot on some platforms
        where the built-in desktop search is not what I need.
    }
  Library: [
     level: 'beginner
     platform: 'all
     type: [function tool]
     domain: [files]
     tested-under: none
     support: none
     license: none
     see-also: none
   ]
]

find-file: func [
    "Returns a block of files where target string was found"
    dir [file!] "Directory path to search"
    filter "File pattern to search or NONE for all, eg: *.r"
    target "String to find"
    /only  "Only search dir, not sub-dirs"
    /local files out
][
    print dir ; watch it go

    if any [not string? filter empty? filter] [filter: "*"]
    files: load dirize dir
    out: copy []

    ; Search only files found in the directory:
    foreach file files [ ; (breadth first)
        if all [
            #"/" <> last file
            find/any file filter
            find read/binary file: dir/:file target ; skip CRLF conversion
        ][
            append out file
        ]
    ]

    ; Now search sub-directories:
    if not only [
        foreach file files [
            if #"/" == last file [
                append out find-file dir/:file filter target
            ]
        ]
    ]
    out
]

;Examples:
;probe find-file %project/ none "example"
;probe find-file %../../ ".r" "rebol"
