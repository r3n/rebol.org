REBOL [
    File: %quick-manual.r
    Date: 14-sep-2009
    Title: "Quick Manual"
    Author:  Nick Antonaccio
    Purpose: {
        A quick and dirty way to print out help for all built in functions.
        Also includes a complete list of VID styles ("view layout" GUI
        widgets), VID layout words, and VID facets (standard properties
        available for all the VID styles).  Give it a minute to run...
        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

print "This will take a minute..."  wait 2
echo %words.txt what echo off   ; "echo" saves console activity to a file
echo %help.txt
foreach line read/lines %words.txt [
    word: first to-block line
    print "___________________________________________________________^/"
    print rejoin ["word:  " uppercase to-string word]  print "" 
    do compose [help (to-word word)]
]
echo off
x: read %help.txt
write %help.txt "VID STYLES (GUI WIDGETS):^/^/"
foreach i extract svv/vid-styles 2 [write/append %help.txt join i newline ]
write/append %help.txt "^/^/LAYOUT WORDS:^/^/" 
foreach i svv/vid-words [write/append %help.txt join i newline]
b: copy [] 
foreach i svv/facet-words [
    if (not function? :i) [append b join to-string i "^/"]
]
write/append %help.txt rejoin [
    "^/^/STYLE FACETS (ATTRIBUTES):^/^/" b "^/^/SPECIAL STYLE FACETS:^/^/"
]
y: copy ""
foreach i (extract svv/vid-styles 2) [
    z: select svv/vid-styles i
    ; additional facets are held in a "words" block:
    if z/words [
        append y join i ": "
        foreach q z/words [if not (function? :q) [append y join q " "]]
        append y newline
    ]
]
write/append %help.txt rejoin [
    y "^/^/CORE FUNCTIONS:^/^/" at x 4
]
editor %help.txt