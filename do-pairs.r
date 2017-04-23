REBOL [
        File: %do-pairs.r
        Date: 08-03-2016
        Author: "Christian  Le Corre"
        Title: "Do pairs"
        Purpose: {Do pairs with values from a block}
]
        
do-pairs: func [param [block!] /rm-conv /local output][
		
		output: make block! []
		either rm-conv 
		[
			foreach v1 param [
				foreach v2 param[
					if all [none? find/only output reduce[v2 v1] not equal? v1 v2][
						append/only output reduce[v1 v2]
					]
				]
			]
		]
		[
			foreach v1 param [
				foreach v2 param[
					if not equal? v1 v2 [
						append/only output reduce[v1 v2]
					]
				]
			]
		]
		unique output	
]


; var: ["toto" "titi" "tutu"]
; res: do-pairs/rm-conv var
; == [["toto" "titi"] ["toto" "tutu"] ["titi" "tutu"]]
; res: do-pairs var
; == [["toto" "titi"] ["toto" "tutu"] ["titi" "toto"] ["titi" "tutu"] ["tutu" "toto"] ["tutu" "titi"]]
	