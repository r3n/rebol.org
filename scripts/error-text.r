REBOL [
	Title: "error-text?"
	File: %error-text.r
	Purpose: "Generate error text given an error object."
	Date: 2-Oct-2002
	Version: 1.0.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	Library: [
		level: 'beginner
		platform: 'all
		type: [tool function]
		domain: [debug utility]
		tested-under: [
			view 2.7.8.3.1 on [Win7] {Basic tests.} "Brett"
		]
		support: none
		license: 'apache-v2.0
		see-also: none
	]
]


error-text?: function [
	"A function to generate normal error message text given an error object."
	error [object!]
][message][
	do bind/copy [
		if block? message: system/error/:type/:id [
			message: bind/copy message 'arg1
		]
		rejoin [
			{** } uppercase/part reform type 1 
			{ Error: } reform message
			{^/** Where: } mold error/where
			{^/** Near: } mold error/near
		] 
	] in error 'self
]	
