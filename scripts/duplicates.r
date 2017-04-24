REBOL [
    	File: %duplicates.r
    	Date: 03-03-2016
        Author: "Christian  Le Corre"
    	Title: "Duplicates"
    	Purpose: {Get duplicated values in a block}
    	]

duplicates: func [param [block!] /sole /local output][
		output: make block! []
		loop length? param [
			if found? find (next param) param/1 [append output param/1] 
			param: next param
		]
		either sole [unique output][output]
	]

probe duplicates [1 1 2 3 4 4 4 5 6 7 7 8 9 9 9 9 10]
probe duplicates/sole [1 1 2 3 4 4 4 5 6 7 7 8 9 9 9 9 10]

; The output is:
;[1 4 4 7 9 9 9]
;[1 4 7 9]