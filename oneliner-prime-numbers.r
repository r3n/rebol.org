REBOL [
	title: "Prime numbers"
	file: %oneliner-prime-numbers.r
	author: "Marco Antoniazzi translated from Wouter van Oortmerssen"
	date: 23-12-2012
	version: 0.0.1
	Purpose: "Give some prime numbers"
	library: [
		level: 'beginner
		platform: 'all
		type: 'one-liner
		domain: [math]
		tested-under: [View 2.7.8.3.1]
		license: 'public-domain
	]
]

  i: 9 j: 99 while[0 <> i: i - 1][if 0 = mod j i[either 0 <> i: i - 1[i: j: j - 2][prin[j" "]]]]halt
