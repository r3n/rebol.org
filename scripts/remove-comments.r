Rebol [
    title: "Remove Comments"
    date: 29-june-2008
    file: %remove-comments.r
    author: Nick Antonaccio
    purpose: {
        A parse example that removes comments from Rebol code.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

code: read to-file request-file
parse/all code [any 
	[
    	to #";" begin: thru newline ending: (remove/part begin ((index? ending) - (index? begin))) :begin
    ]
]
editor code