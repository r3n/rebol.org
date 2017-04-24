REBOL [
    Title: "Script Library Submission Processor (CGI side)"
    Date: 17-May-2001/21:10
    Version: 1.0.5
    File: %post-script.r
    Author: "Carl Sassenrath"
    Purpose: {Accepts a new or changed script for the script Library.
Inspects the script's header first.  Updates all
related library index files.
}
    Email: carl@rebol.com
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: [cgi ldc] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

print "Content-type: text/html^/^/"

site-path: %/home/WWW_pages/rebol/
lib-path: site-path/library
log-file: site-path/add-script-log.txt

field-types: [
    title   [string!]
    author  [string!]
    date    [date!]
    version [tuple!]
    file    [file!]
    purpose [string!]
    category [block!]
]

valid-cats: [
    view vid email web markup  
    ftp cgi net tcp ldc    
    script tutor file text 
    db crypt lib shell
    math util misc game
    sound compress all
    1 2 3 4 5
]

check-type: func [word types /local var] [
    var: all [var: in hdr word  get var]
    if all [any-string? var empty? var] [var: none]
    if not all [var find types type?/word var] [
        return reform ["REBOL header requires" word "field of" types]
    ]
    none
]

check-all: does [
    foreach [fld type] field-types [
        if val: check-type fld type [return val]
    ]
]

add-file: func [ifile file /local name] [
    name: to-string hdr/file
    clear find/last name ".r"
    lowercase hdr/file
    write/append ifile reform [
        newline "file"
        mold name
        mold join %scripts/ hdr/file
        "info" mold hdr/title
        remold [size? file hdr/date]
    ]
]

certify: func [script /local msg file old] [
    msg: none
    either all [
        msg: "REBOL header not found"
        script? script
        msg: "Script cannot be loaded"
        not error? do [hdr: load/header script]
        hdr: first hdr
        not msg: check-all
    ][
        write/append log-file reform [hdr/file now newline]
        file: hdr/file
        file: lib-path/scripts/:file
        if not hdr/date/time [hdr/date/time: 0:00]
        if exists? file [
            if error? try [old: first load/header file][
                print "Problem with existing script. RT will investigate the problem."
                send carl@rebol.com script
                exit
            ]
            if not all [
                old/file = hdr/file
                old/title = hdr/title
                old/author = hdr/author
            ][
                print trim/auto {
                    Script with that filename already exists under a different
                    title, file, or author. Contact REBOL Technologies directly
                    if you must change those fields.
                }
                exit
            ]
            if old/version >= hdr/version [
                print join "The new version number needs to be greater than: " old/version
                exit
            ]
            if not old/date/time [old/date/time: 0:00]
            if old/date >= hdr/date [
                print join "The new date must be more recent than: " old/date
                exit
            ]
        ]
        write file detab script
        append hdr/category 'all
        foreach cat intersect hdr/category valid-cats [
            ifile: lowercase join %idx- [cat ".r"]
            ifile: lib-path/:ifile
            either exists? ifile [
                data: load ifile
                either data: find data join %scripts/ hdr/file [
                    data: find data block!
                    change/only data reduce [size? file hdr/date]
                    write ifile join "REBOL [type: 'index]^/^/" mold/only head data
                ][
                    add-file ifile file
                ]
            ][
                write ifile "REBOL [type: 'index]^/^/"
                add-file ifile file
            ]
        ]
        print "ok"
    ][
        print msg
    ]
]

data: make string! 4096
buffer: make string! 10002
while [not zero? read-io system/ports/input buffer 10000][
    append data buffer
    clear buffer
]
;probe buffer
certify data
