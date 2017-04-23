REBOL [
	Date: 23-Sep-2010/11:01:22+2:00
	Author: "Ladislav Mecir"
	File: %ifunc.r
	Title: "Ifunc"
	Purpose: {
		Sometimes it is optimal to do some things just once,
		during a "function initialization phase", instead of doing them
		every time the function is called.
		
		An example of this may be a creation of USE-RULEs, that can be done
		just once, instead of being done every time the function is called.
		
		Such an initialization can be easily done in R2,
		but is problematic in R3 due to "excessive" protection.
		
		This is a way how to circumvent the protection in R3.
	}
	Notes: {
		The present solution uses a special 'init? variable for the
		initialization purposes. This variable must not be used
		as an argument (local variable) of the function being defined.
		
		At the price of a more complicated and slower implementation,
		we can get rid of this limitation, but it does not look like
		being worth the effort.
	}
]

ifunc: func [
	spec [block!] {
		Help string (opt) followed by arg words 
		(and opt type and string)
	}
	init [block!] {initialization code}
	body [block!] "The body block of the function"
] [
	make object! [
		init?: func [init] [do init init?: none]
		set 'body append compose/only [init? (init)] body
	]
	func spec body
]

comment [
	fr: ifunc [] [initialized: now] [
		print ["this function was initialized:" initialized]
	]
	fr ; this function was initialized: 22-Sep-2010/9:36:22+2:00
]
