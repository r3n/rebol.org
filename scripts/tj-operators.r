REBOL[
	File: %tj-operators.r
	Date: 27-Dec-2006
	Title: {Custom math operators}
	Purpose: {Math shorthand. Used by other of my library functions. Rollover operator}
	Author: "Tim Johnson"
	email: tim@johnsons-web.com
	NOTE: {'++ is copied directly from the REBOL docs, '-- and '++- based on '++}
	Library: [
		level: 'beginner
		platform: 'all
		type: [Function one-liner]
		domain: [math]
		tested-under: "Linux, CGI"
		support: ["Tim Johnson" tim@johnsons-web.com]
		license: none
		see-also: none
		]
	]
;  -----------------------------------------------------------------------------------------
div: func[ {returns [quotient remainder]} dividend[integer!] divisor[integer!]
 	      /obj {return context[quot: n rem: n]}
 	][ 
 	either obj[
 		make object! compose[
 			quot: (to-integer dividend / divisor)
 			rem: (dividend // divisor)
 			]
 		][ reduce[to-integer dividend / divisor dividend // divisor] ]
 	]
;  -----------------------------------------------------------------------------------------
++: func[ {increments a value} 'word ] [ set word 1 + get word ]
;  -----------------------------------------------------------------------------------------
 --: func[ {decrements a value} 'word ] [ set word -1 + get word ]
;  -----------------------------------------------------------------------------------------
++-: func[ {increments a value. If it exceeds limiter (or length of limiter), reset to 1} 
 	'word limiter[number! series!] /local limit][ 
 	limit: either series? limiter[length? limiter][limiter]
 	set word 1 + get word 
 	if (get word) > limit[set word 1]
 	]
;  -----------------------------------------------------------------------------------------
;  '++- is very useful for interating over a series and "rolling back" to the first
;    element when past end. 
;  -----------------------------------------------------------------------------------------
comment {
  CONSOLE EXAMPLES FOLLOW
  ----------------------- 
>> do %operators++.r
>> a: 1
== 1
>> ++ a
== 2
>> -- a
== 1
>> s: "abcd"
== "abcd"
>> loop 6[++- a s print s/:a]
b
c
d
a
b
c
>> div 11 4
== [2 3]
>> t: div/obj 11 4
>> probe t
make object! [
    quot: 2
    rem: 3
]
}
