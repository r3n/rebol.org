Rebol [
	title: "Compute the date of Easter day"
	author: "Didier Cadieu, but many more"
	date: 1-mar-2005
	version: 1.1.0
	file: %easter-day.r
	purpose: {
		Just a small function to compute the date of the Easter day.
		Can be used to compute other dates related to Easter.
		
		Should be accurate for years starting at 1583 to 2050, and
		maybe more.
	}
	comment: {
		I have implemented this function from known algorithm.
		Many others have done the same (TomC, Allen Kamp...)

		I have just uploaded to the Library before them ;-)		
	}
	history: [
		1.0.0 25-02-2005 {First release.}
		1.1.1 01-03-2005 {Litle optimisation in the computation and locales words.}
	]
	library: [
		level: 'beginner 
		platform: 'all
		type: [function]
		domain: [math scientific]
		tested-under: [View 1.2.48.3.1 WinWP]
		support: none
		license: 'public-domain
		see-also: none
	]

]

easter-day: func [
	{Compute the easter date for the wanted year.}
	year [integer!] {Year for whitch you want the easter date}
	/local a b c d z f g h i k
] [
	a: year // 19
	b: to integer! year / 100
	c: year // 100
	d: to integer! b / 4
	z: b // 4
	f: to integer! b + 8 / 25
	g: to integer! b - f + 1 / 3
	h: 19 * a + b - d - g + 15 // 30
	i: to integer! c / 4
	k: c // 4
	c: z + i * 2 + 32 - h - k // 7
	b: to integer! a + (11 * h) + (22 * c) / 451
	a: h + c - (7 * b) + 114
	to date! reduce [
		a // 31 + 1
		to integer! a / 31
		year
	]
]

