Rebol[
file: %easter.r 
title: "dates of easter" 
date: 28-Feb-2005 
purpose: "find the date Easter will fall on for a particular year"
library: [
        level: 'beginner
        platform: 'all
        type: 'tool
        domain: 'text
        tested-under: [xp solaris]
        support: none
        license: none
        see-also: none
    ]
]

easter?: func [ {given a year returns the date of easter.
    lifted from "Astronomical Formulae for Caculators" pp 31 by Jean Meeus 1979
    algorithm attributed to a 1876 publication
    note: I am adding a + 1 to the day to account for an appearent rounding error
    }
    x[integer!] "(Gregorian) year"
 /local a b c d e f g h i k l m n p
][  a: x // 19
	b: to integer! (x /  100) c: x // 100
	d: to integer! (b /  4)   e: b // 4
	f: to integer! (b + 8 / 25)
	g: to integer! (b - f + 1 / 3)
	h: 19 * a + b - d - g + 15 // 30
	i: to integer! (c / 4)     k: c // 4
	l: 32 + e + e + i + i - h - k // 7
	m: to integer! (11 * h + a + (22 * l) / 451)
	n: to integer! (h + l - (7 * m) + 114 /  31)
	p: h + l - (7 * m) + 114 // 31
	to date! reduce[x n p + 1]
]