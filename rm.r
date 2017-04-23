REBOL [
    File: %rm.r
    Date: 10-Jun-2006
    Title: "Remove part of a string using parse"
    Purpose: {
         When use with "foreach line lines" to remove specific columns in a text file. 
         e.g. remove column 10 to column 13 in file.txt
         lines: read/lines %file.txt
         foreach line lines [
               parse/all line [9 skip mark: (remove/part mark 4) to end]
         ]
         write %file.txt lines
    } 
    library: [
                level: 'beginner
        	platform: 'all
        	type: [one-liner]
        	domain: [text-processing text]
        	tested-under: [win2k version 1.3.2.3.1]
        	support: none
        	license: none
        	see-also: none
    ]
]
parse/all str:"This is a one liner" [9 skip mark: (remove/part mark 4) to end (print str)]	    
halt