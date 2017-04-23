REBOL [
    title: "chmod777to555"
    date: 18-Apr-2010
    file: %chmod777to555.r
    author:  Nick Antonaccio
    purpose: {
        I use this script to make sure that there are no files chmod'd to 777
        on my webservers.  Built in is a routine that collects and writes the 
        name of every folder and every file on my server, to a text file.
        Taken from the tutorial at http://re-bol.com
    }
]

start-dir: what-dir
all-files: to-file join start-dir %find777all.txt

write all-files ""

recurse: func [current-folder] [
    out-data: copy ""
    write/append all-files rejoin["CURRENT_DIRECTORY:  " what-dir newline]
    call/output {ls -al} out-data
    write/append all-files join out-data newline
    foreach item (read current-folder) [ 
        if dir? item [
            change-dir item 
            recurse %.\
            change-dir %..\
        ] 
    ]
]
recurse %.\

file-list: to-file join start-dir %found777.txt
write file-list ""
current-directory: ""
foreach line (read/lines all-files) [
    if find line "CURRENT_DIRECTORY:  " [
        current-directory: line
    ]
    if find line "rwxrwxrwx" [
        write/append file-list rejoin [
            (find/match current-directory "CURRENT_DIRECTORY:  ")
            (last parse/all line " ")
        ]
        write/append file-list newline
    ]
]

foreach file (read/lines file-list) [
    call rejoin [{chmod 755 } (to-local-file file)]
]