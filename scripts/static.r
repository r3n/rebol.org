REBOL [
	Title: "Static"
	Date: 24-Dec-2003
	File: %static.r
	One-liner-length: 114
	Author: "Vincent Ecuyer"
	Purpose: {Functions with static vars}
	Usage: {
		static <block of static vars with initial values> <function>
		
		count: static [n: 0] does [n: n + 1]
		> count == 1
		> count == 2
		...

		As a side effect, funcs can be referenced by 'self :

		fact: static [] func [n][either n < 2 [1][n * self n - 1]]
	}
 	Library: [
 	        level: 'intermediate
 	        platform: 'all
 	        type: [function one-liner]
 	        domain: [UI extension]
 	        tested-under: none
 	        support: none
 	        license: none
 	        see-also: none
 	]
]

static: func [vars [block!] func [function!]][vars: context vars bind second :func in vars 'self vars/self: :func]
