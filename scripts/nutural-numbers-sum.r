REBOL [
    	File: %nutural-numbers-sum.r
    	Date: 26-9-2014
    	Title: "Natural numbers sum"
    	Purpose: {
                       Sums all the natural numbers up to
                       a given input.
                       Uses the equality:
                       1 + 2 + 3 +... + n = n*(n+1)/2
                       to avoid looping.
                       }
        Author: "Caridorc"
            library: [
                               level: 'beginner
                               platform: 'all
                               type: [tutorial tool]
                               domain: [math]
                               tested-under: "Windows"
                               support: riki100024 AT gmail DOT com
                               license: {CC 3.0 Attribution only}
                               see-also: none
    ]
]


view layout [
	across
	button "Sum of all the natural numbers up to " 400x30 font-size 20 [alert to-string ((to-integer a/text) * ((to-integer a/text) + 1) / 2)]
	a: field font-size 20 200x30
	]