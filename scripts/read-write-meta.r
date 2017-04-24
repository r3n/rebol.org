REBOL [
	Author: "Ashley G Truter"
	File: %read-write-meta.r
	Date: 28-Jun-2009
	Title: "Read & Write metadata"
	Purpose: {
		Easily access streams (Windows NTFS) and resource forks (Mac OS X HFS). Linux/Unix not supported.
	}
	Usage: {
		write %test.txt "a"
		write-meta %test.txt "b"
		write-meta/append %test.txt "c"
		read %test.txt
		read-meta %test.txt

		WARNING! Copying a file from NTFS/HFS to a non-NTFS/HFS file system (e.g. FAT32) will result in
		the file metadata being lost.
	}
	library: [
		level: 'beginner
		platform: [windows mac]
		type: [tool function]
		domain: [file-handling]
		tested-under: [view 2.7.6 [WinXP MacOSX]]
		support: none
		license: 'public-domain
		see-also: none
	]
]

read-meta: make function! [
	"Reads metadata from a file."
	file [file!]
] [
	read join file switch fourth system/version [
		2	[%/..namedfork/rsrc]	; Mac HFS
		3	[":rsrc"]				; Windows NTFS
	]
]

write-meta: make function! [
	"Writes metadata to a file."
	file [file!]
	data [any-type!]
	/append "Writes to the end of an existing file."
] [
	file: join file switch fourth system/version [
		2	[%/..namedfork/rsrc]	; Mac HFS
		3	[":rsrc"]				; Windows NTFS
	]
	either append [write/append file data] [write file data]
]