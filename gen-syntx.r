rebol[
    File: %gen-syntx.r
    Author: "Tom Conlin"
    Date: 10-Apr-2003
    Title: "generate syntx"  
    Library: [
        level: 'intermediate        
         platform: 'all        
         type: [function reference tool]       
         domain: [text ]        
         tested-under: none        
         support: none        
         license: none        
         see-also: none
    ]   
    Purpose: {
        generate the list of defined 'words separated by their 'type
        I used the list as a basis for syntax coloring in an editor  
        
        works with versions before core 2.5.5 but does not return natives in core 2.5.5
        works with some since then as well
    }
    to-use: {run the script then use the contents the file 'xyz-f'}
]   
echo %xyz-f
    help datatype! 
echo none 
xyz-a: read/lines %xyz-f 
remove xyz-a
xyz-c: rejoin [";;;" tab system/product tab system/version tab now/date newline]
foreach xyz-d xyz-a [
	xyz-d: pick parse xyz-d none 1 
	echo %xyz-f
		do rejoin ["help " xyz-d] 
	echo none
	xyz-b: read/lines  %xyz-f
	;print [xyz-d xyz-b/1]
	if equal? "Found these words:" trim xyz-b/1 [
		remove xyz-b  
		insert tail xyz-c rejoin [";;;;;;;;;;;;;;;;;; " uppercase copy xyz-d newline]
		xyz-e: rejoin ["(" head remove back tail copy xyz-d ")"];;; pre /core-2.5.5    
		foreach xyz-g xyz-b [        
			xyz-g: parse xyz-g none
			print [xyz-g/1 xyz-g/2]
			if all[ (string? xyz-g/1)
					(not equal? xyz-g/1 "")
					(not equal? "xyz-" copy/part xyz-g/1 4)
					any [xyz-g/2 = xyz-e xyz-g/2 = xyz-d]] [
				if equal? xyz-e "(op)" [insert xyz-g/1 " " insert tail xyz-g/1 " "]
				insert tail xyz-c join xyz-g/1 [newline]
			]
		] 
	]
]
write %xyz-f xyz-c