REBOL
[
	File: %substr.r
        Date: 16-Dec-2003
        Title: "Simple substring function - with the addition of error message to prevent  'none' shown"
        Purpose: "Working around string series"
         Author:  "Yosef H. da Iry"
         library: [
                      level: 'beginner
                      platform: 'all 
                      type: [tutorial tool] 
                      domain: [text text-processing]
                      tested-under: none 
                      support: none license: none 
                      see-also: none ]
]




substr: func ["Substring function"
	str [string! word!] "string"
	start-index "started index"
	/slen "refinement"
	 len  "number of characters to be taken"]
	
	[
		size: length? str
		
		either slen
		[
			either start-index + len > size
			[
				print "ERROR !! Substring operation over-limit the string size !!"
			]
			
			[
				;create a new string block for the new string
				;the length is equal to len
		
					new-str: make string! len
			
		
				;calculating the end-index
			
					end-index: start-index + len - 1
			
			
		
					
				;copying the content
			
					for i start-index end-index 1
					[
						char: pick str i
						append new-str char
					]
		
				;print new string
					print new-str
			]
		]
		
		[
			either start-index > size
			[
				print "ERROR !! Substring operation over-limit the string size !!"
			]
			
			[
				;traversing the block up to the desired start-index
				loop start-index
				[
					str: next str
				]
			
				;move one back due to the loop above
				str: back str
			
				;copy the new string
				new-str: copy str
			
				;print new string
				print new-str
			]			
		]
			
		
		
		
		
	]