REBOL [
    	File: %diary.r
    	Date: 20-9-2014
    	Title: "Diary"
    	Purpose: {
                       This programme allows you to simply keep a diary
                       It writes to a plain text file the *** title *** 
                       and the body, automatically adding Date and Time.
                       }
        Author: "Caridorc"
        library: [
        level: 'beginner
        platform: 'all
        type: [tool]
        domain: []
        tested-under: "Windows rebol view 2.7"
        support: none
        license: GNU
        see-also: none
    ]
] 


view layout [
    across
	text "Title" font-size 32
	Title: field 400x50 font-size 32
	below
	across
    text "Text" font-size 32
    Content: area font-size 24
	below
	button "Save" font-size 16 [
	    write/append request-file/only (rejoin ["Date: " now/date newline "Time: " now/time newline "*** " Title/text " ***"  newline Content/text newline newline])
	    alert "Saved"
		]
	]