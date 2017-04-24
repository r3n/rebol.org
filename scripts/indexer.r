REBOL [ 
	Title: "Indexer"
	Author: "Massimiliano Vessi"
	Email: maxint@tiscali.it
	Date: 24-Aug-2009
	version: 3.1.1
	file: %indexer.r
	Purpose: {"Add to index.r all the files and directory of the current directory"}
	;following data are for www.rebol.org library
	;you can find a lot of rebol script there
	library: [ 
		level: 'beginner 
		platform: 'all 
		type: [tutorial tool] 
		domain: [ file-handling files 'parse sdk text-processing user-interface ui visualization ] 
		tested-under: [windows linux] 
		support: none 
		license: [gpl] 
		see-also: none 
		] 
	]



a: system/script/header



either exists? %index.r [a: load/header %index.r] [ alert "Plese edit index.r header with your data. Next time this message will not be shown."]

indexing_func: func [ /local var1] [ 
	;increment version
	b: do first a
	if b/version = none [b/version: 0.0.0]
	c: 0.0.0
	c/3: b/version/3 + 1
	if c/3 > 255 [  c/3: 0 
		c/2: b/version/2 + 1
		]
	if c/2 > 255 [  c/2: 0 
		c/1: b/version/1 + 1
		]

	var1:  to-string reduce [ 
		{REBOL [Title: ^"Local Index^" 
		Type: 'index 
		Author: } 
		b/Author
		"^/Email: " 
		b/email
		"^/Version: "
		c
		"^/Date: "
		now
		{]
		^/ ^/
		title: "Local Files" 
		file "Contact" }
		b/email
		" ^/ ^/"
		]

	foreach file read %. [
		info: info? file
		if dir? file [ 
			append var1 "folder "
    			append var1 "^""
    			trim/all  file ;remove all spaces frome file name, it's a problem with view
    			append var1 file
    			append var1 "^" %"
    			append var1 file
    			append var1 "^/ ^/"
			change-dir  file
			indexing_func
			change-dir %..
			]
		if not (dir? file) [ 
			append var1 "file "
    			append var1 "^""
    			append var1 file
    			append var1 "^" %"
    			trim/all  file ;remove all spaces frome file name, it's a problem with view
    			append var1 file
    			append var1 "^/ ^/"
			]    				
		]

	write %index.r   var1
	]
	
indexing_func	

alert "Done!"