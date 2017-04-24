REBOL [
	Title: "Delimit"
	File: %delimit.r
	Purpose: "Delimit series elements with a delimiter."
	Date: 4-Mar-2013
	Version: 1.0.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	Library: [
		level: 'beginner
		platform: 'all
		type: [tool function]
		domain: [utility text-processing]
		tested-under: [
			view 2.7.8.3.1 on [Win7] {Basic tests.} "Brett"
		]
		support: none
		license: 'apache-v2.0
		see-also: none
	]
]


delimit: func [
	{Intersperse series elements with a delimiter.}
	series [series!]
	delimiter [any-type!]
	/local result
][
	if 2 > length? series [return copy series]
	result: head insert/only make type? series 2 * (length? series) first series
	repeat e next series [insert tail result reduce [:delimiter :e ]] 
	result
]