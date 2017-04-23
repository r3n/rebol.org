REBOL [
    title: "Simple Search"
    date: 17-may-2009
    file: %simple-search.r
    author:  Nick Antonaccio
    purpose: {
        Searches though all files in all subdirectories to find given text in each file. 
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
        (a website CGI version of the script is also given in the tutorial).
    }
]

phrase: request-text/title/default "Text to Find:" "the"
start-folder: request-dir/title "Folder to Start In:"
change-dir start-folder
found-list: ""

recurse: func [current-folder] [ 
    foreach item (read current-folder) [ 
        if not dir? item [
            if find (read to-file item) phrase [
                print rejoin [{"} phrase {" found in:  } what-dir item]                 
                found-list: rejoin [found-list newline what-dir item]
            ]
        ]
    ]
    foreach item (read current-folder) [ 
        if dir? item [
            change-dir item 
            recurse %.\
            change-dir %..\
        ] 
    ]
]

print rejoin [{SEARCHING for "} phrase {" in } start-folder "...^/"]
recurse %.\
print "^/DONE^/"
editor found-list
halt



cgi-version: [

#! /home/yourpath/public_html/rebol/rebol -cs
REBOL []
print "content-type: text/html^/"
print [<HTML><HEAD><TITLE>"Search"</TITLE></HEAD><BODY>]
; print read %template_header.html

submitted: decode-cgi system/options/cgi/query-string

if not empty? submitted [
    phrase: submitted/2
    start-folder: to-file submitted/4
    change-dir start-folder
    found-list: ""
    
    recurse: func [current-folder] [ 
        foreach item (read current-folder) [ 
            if not dir? item [  if error? try [
                if find (read to-file item) phrase [
                    print rejoin [{"} phrase {" found in:  } what-dir item {<BR>}]
                    found-list: rejoin [found-list newline what-dir item]
                ]] [print rejoin ["error reading " item]]
            ]
        ]
        foreach item (read current-folder) [ 
            if dir? item [
                change-dir item 
                recurse %.\
                change-dir %..\
            ] 
        ]
    ]
    
    print rejoin [{SEARCHING for "} phrase {" in } start-folder {<BR><BR>}]
    recurse %.\
    print "<BR>DONE <BR>"
    ; save %found.txt found-list
    ; print read %template_footer.html
    quit
]

print [<CENTER><TABLE><TR><TD>]
print [<FORM ACTION="./search.cgi">]
print ["Text to search for:" <BR> <INPUT TYPE="TEXT" NAME="phrase"><BR><BR>]
print ["Folder to search in:" <BR> <INPUT TYPE="TEXT" NAME="folder" VALUE="../yourfolder/" ><BR><BR>]
print [<INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">]
print [</FORM>]
print [</TD></TR></TABLE></CENTER>]
; print read %template_footer.html 


]