REBOL [
	Title: "Geek Within Automated Helper"
	Date: 23-Mar-2004
	Author: "Bohdan Lechnowsky"
	File: %geekwithin.r
	Email: LTC@sonic.net
	Purpose: {
		Defines a helpful assistant (unlike Microsoft's) that actually shows where to click to perform a set of instructions
		Meant to be plugged-in to existing Rebol/View applications
	}
	Notes: {
		Includes full-sized graphics embedded as a compressed binary - hence the
			large script size
		Originally part of a much-larger application written for a client of
			Lechnowsky Technical Consulting
		There may exist some bugs as I more-or-less ripped the functions from the
			much-larger application and haven't tested much
		It would be nice to have more animation of the assistant ("Geek Within" or
			"GW") and enhancements to the functions included
		Also, in this version there are a lot of globally-defined words, would be nice
			to have them in a context
	}
	License: {
		REQUIRED:
		If you use the geek within (or parts thereof) as part of another
			script/product, please let me know the name of the script/product and
			where I can see a sample of how it was used (demo download, etc.).

		NOT REQUIRED:
		If you make money off a script/product that contains the geek within or
			offshoot thereof, please consider sending a small contribution from the
			proceeds to help feed my wife and four children.  I don't mind eating
			their leftovers. :-)
	}
	Library: [
		level: 'advanced
		platform: 'all
		type: [function module tool package]
		domain: [ui user-interface vid]
		support: ltc@sonic.net
		license: []
		tested-under: [win]
	]
]

;;	================================================================
;;  This script is a *package*. What you see here is just the
;;  stub.  Run this and select the geekwith.r package to download it
;;	================================================================

do http://www.rebol.org/library/public/repack.r