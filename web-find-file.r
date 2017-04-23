REBOL [
    Title: "Find a file in sites "
    Date: 9-Nov-2012
    Name: 'find-file
    File: %web-find-file.r
    Version: 3.0.0
    Author:  "Massimiliano Vessi"
    Purpose: "Finding web page containing a text, also crawling on all page links"
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
	dir [url!] "website to scan"
	deep "Deep page limit"
	target "String to find"
	/only  "Only search dir, not sub-dirs"
	/local files out lis lis2 temp file
	][
	-- deep
	append db dir
	aaa/text: reform ["Scanning" dir]
	show aaa    
	out: copy []    
	;serch for text
	file: ""	
	attempt [file: read/binary dir  ];skip CR/LF conversio, quicker
        if    find  file  target  [  append out dir ]
    
	; serch for links in page and put them in lis2 block
	lis: copy []
	lis2: copy []
	parse file  [any [thru {href=} copy temp to ">" (append lis temp) ]] 
	foreach item lis [
		temp: parse item none
		either sd/data [
			temp2: decode-url (to-url temp/1)
			if temp2 = none [temp2: make object! [host: none ]]
			if orig/host = temp2/host [append lis2 (to-url temp/1)]
			][append lis2 (to-url temp/1)]
		
		result: copy lis2
		show   bbb
		]
	
	
    ; Now search in link
	if deep > 0 [
		foreach dir lis2 [   if not (find db dir)  [ append out find-file dir deep target  ]   ]
	]    
    out
]

;Examples:
;probe find-file http://www.rebol "example"
;probe find-file %../../ ".r" "rebol"

dir: %./
n: 0
result:  copy []

view layout [
Title "Web page finder"
across
label 80 "Text to search"
text-f: field 
return 
label 80 "Deep of search" 
filter-f: field "5"
return 
label  80 "Starting page" 
dir-f: field "www.rebol.com"
return
label 80 "Only same domain"
sd: check true 
return
btn green "Search..." [
	db: copy []	
	if not (parse dir-f/text  ["http://" to end]) [insert dir-f/text  "http://" ]
	orig: decode-url  (to-url dir-f/text)
	result: find-file   (to-url dir-f/text) ( to-integer filter-f/text) text-f/text
	aaa/text: "DONE!"
	show aaa
	show bbb
	]
btn-help [view/new layout [title "Help "
text as-is  200 {
This script search for web page an in subpage containing the text you specify.
You must specify deep, I decide this to avoid to scan the entire world wide web!
Another important feature is that you can check only the starting domain.
Examples:
probe find-file http://www.rebol.com  10  "Carl"
}
text bold "Author: Max Vessi"
text bold "maxint@tiscali.it"
]]	
return 
aaa: text  300x40
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




