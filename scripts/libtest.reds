Red/System []

LIBTEST_Add: func [
	a [integer!]
	b [integer!]
	return: [integer!]
	][
	a + b
]
LIBTEST_Incmem: func [
	a [pointer! [integer!]]
	][
	a/value: a/value + 1
]

#export [LIBTEST_Incmem LIBTEST_Add]

#if OS = '???? [{
REBOL [
	Title: "Shared lib example"
	file: %libtest.reds
	date: 01-01-2014
	version: 0.0.1
	Author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	Rights: "Copyright (c) 2014 Marco Antoniazzi"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Requires: {Rebol2 and Red/System >= 0.4.1}
	Purpose: "This is a simple example of a shared library, written in Red/System."
	Help: "You must execute this script with Rebol2"
	library: [
		level: 'advanced
		platform: 'windows
		type: how-to
		domain: [external-library]
		tested-under: [View 2.7.8.3.1 Red/System 0.4.1]
		support: none
		license: none
		see-also: none
	]
]
appname: "libtest"
dest: join what-dir appname
change-dir %../../../Others/Red/Red-master-0.4.1-20131227                ; locate here your red directory

do/args %red.r rejoin [" -dlib -o %" dest " %" dest %.reds ]

; test the library (this part is obviously normally on a separate file)

	int-ptr: does [make struct! [value [integer!]] none]

	lib: load/library %libtest.dll

	LIBTEST_Add: make routine! [
		a [integer!]
		b [integer!]
		return: [integer!]
	] lib "LIBTEST_Add"

	LIBTEST_Incmem: make routine! [
		a [struct! [value [integer!]]]
	] lib "LIBTEST_Incmem"
	
	print LIBTEST_Add 2 3 ; should print 5
	a: int-ptr
	a/value: 3
	LIBTEST_Incmem a
	print a/value ; should print 4
	
	free lib

halt
;}]
