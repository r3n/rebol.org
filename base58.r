REBOL [
	Title: "Encode/Decode Base58"
	Date:  5-Dec-2009
	Author: "Christopher Ross-Gill"
	File: %base58.r
	Version: 1.0.0
	Home: http://www.ross-gill.com/
	Purpose: {
		To Encode Integers as Base58.
		Used by some URL shortening services.
	}
	Library: [
		level: 'intermediate
		platform: 'all
		type: [function module]
		domain: [web]
		tested-under: [view 2.7.6.2.4 view 2.100.95.2.5]
		license: 'cc-by-sa
	]
	Example: [
		probe "nh" = to-base58 1234
		probe 1234 = load-base58 "nh"
		browse join http://flic.kr/p/ to-base58 #2740009121
	]
]

to-base58: use [ch out][
	ch: "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ"

	func [id [number! issue!]][
		id: load form id
		out: copy ""
		while [id > 0][
			insert out ch/(round id // 58 + 1)
			id: to-integer id / 58
		]
		out
	]
]

load-base58: use [out ch os][
	ch: "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ"
	os: [
		1 58 3364 195112 11316496 656356768 38068692544
		2207984167552 128063081718016 7427658739644928
	]

	func [id [string! issue!]][
		out: 0
		foreach dg id [insert id: [] -1 + index? find/case ch dg]
		forall id [out: os/(index? id) * id/1 + out]
	]
]