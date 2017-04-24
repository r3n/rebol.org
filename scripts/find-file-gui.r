REBOL [
    Title: "Find a file in directories / folders"
    Date: 20-Jun-2002
    Name: 'find-file
    File: %find-file-gui.r
    Version: 2.0.0
    Author:  "Massimiliano Vessi" ; original was "Carl Sassenrath" 
  Library: [
     level: 'beginner
     platform: 'all
     type: [function tool]
     domain: [files]
     tested-under: none
     support: none
     license: gpl
     see-also: none
   ]

]
find-file: func [
    "Returns a block of files where target string was found"
    dir [file!] "Directory path to search"
    filter "File pattern to search or NONE for all, eg: *.r"
    target "String to find"
    /only   "Only search dir, not sub-dirs"
  /local files out
][
   
  ; print dir ; watch it go
  aaa/text: reform ["Scanning" dir]
  show aaa
    if any [not string? filter empty? filter] [filter: "*"]
    files: load dirize dir
    out: copy []
    ; Search only files found in the directory:
    foreach file files [; (breadth first)
        if all [
            #"/" <> last file
            find/any file filter
            find read/binary file: dir/:file target ; skip CRLF conversion
        ][
            append out file
      result: copy out
      show   bbb
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

dir: %./
n: 0
result:   copy []
view layout [
Title "File finder"
across
tabs 10
label "Text to search"
tab tab
text-f: field
return
label "Extension filter"
tab
filter-f: field ".r"
return
label "Directory"
tab tab
dir-f: field "./"
btn "..." [temp:   request-dir  
    if temp [dir-f/text:   temp]
    show dir-f]
return
btn green "Search..." [result: find-file   (to-file dir-f/text)   filter-f/text text-f/text
        aaa/text: "DONE!"
    show aaa
    show bbb
    ]
btn-help [view/new layout [title "Help "
text as-is {
This script search for files in directory and sub-directories
containing the text you specify.
You can specify all file with the *   (jolly char).
Examples:
probe find-file %project/ none "example"
probe find-file %../../ ".r" "rebol"
}
text bold "Author: Max Vessi"
text bold "maxint@tiscali.it"
]]  
return
aaa: text 300
return
label "Search result:"
return
bbb: list 304x292 [info 300] supply [
    count: count + n
    face/text: result/:count]
scroller 16x292 [
        n:   to-integer (face/data * (length? result) )        
        nmax: (length? result) - 12
        if nmax < 0 [nmax: 0]
        if n > nmax [n: nmax]
        show bbb
        ]          
]