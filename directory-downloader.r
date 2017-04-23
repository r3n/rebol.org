Rebol [
    title: "Directory Downloader"
    date: 29-june-2008
    file: %directory-downloader.r
    author: Nick Antonaccio
    purpose: {
        Download all files and subfolders from a given folder on a web server.
        Used to transfer entire folder structures via network.  Currently configured
		for the aprelium web server (http://aprelium.com/), but easily adjusted for
		others.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

avoid-urls: [
    "/4/"
]

copy-current-dir: func [
{
    Download the files from the current remote directory
    to the current local directory and create local subfolders
    for each remote subfolder.  Then recursively do the same
    thing inside each sub-folder.
} 
    crfu  ; current-remote-folder-url
    clf   ; current-local-folder
    lrf   ; local-root-folder
] [
    foreach avoid-url avoid-urls [
        if find crfu avoid-url [return "avoid"]
    ]
    if error? try [page-data: read crfu] [
        write/append %/c/errors.txt rejoin [
            "error reading (target read error): " 
            crfu newline]
        return "index.html"
    ]
    if not find page-data {Powered by <b><i>Abyss Web Server} [
        write/append %/c/errors.txt rejoin [
            "error reading (.html read error): " 
            crfu newline]
        return "index.html"
    ]
    files: copy []
    folders: copy []
    parse page-data [
        any [
            thru {href="} copy temp to {"} (
                last-char: to-string last to-string temp
                either last-char = "/" [
                ; don't go upwards through the folder structure:
                    if not temp = "../" [
                        append folders temp
                    ]
                ][
                    append files temp
                ]
            )
        ] to end
    ]
    foreach file files [
        if not file = "http://www.aprelium.com" [
            print rejoin ["Getting: " file]
            new-page: rejoin [crfu "//" file]
            replace new-page "///" "/"
            if not exists? to-file file [
                either error? try [read/binary to-url new-page][
                    write/append %/c/errors.txt rejoin [
                        "There was an error reading:  " new-page
                        newline]
                ] [
                if error? try [
        write/binary to-file file read/binary to-url new-page
                ][
                    write/append %/c/errors.txt rejoin [
                    "error writing: " 
                    crfu newline]]
                ]
            ]
        ]
    ]
    if folders = [] [return none]
    recurse: func [folder-name] [
        change-dir to-file folder-name
        crfu: rejoin [crfu
            folder-name]
        clf: rejoin [clf
            folder-name]
        copy-current-dir crfu clf lrf
        change-dir %..
        replace clf folder-name ""
        replace crfu folder-name ""
    ]
    foreach folder-name folders [
        make-dir to-file folder-name
        recurse folder-name
    ]
]

; insert the url of the server here:
initial-pageurl: to-url request-text/default {http://192.168.1.4:8001/4/}
initial-local-dir: copy initial-pageurl
replace initial-local-dir "http://" ""
replace/all initial-local-dir "/" "_"
replace/all initial-local-dir "\" "__"
replace/all initial-local-dir ":" "--"
lrf: to-file rejoin [initial-local-dir "/"]
if not exists? lrf [make-dir lrf]
change-dir lrf
clf: lrf
copy-current-dir initial-pageurl clf lrf
print "DONE" halt