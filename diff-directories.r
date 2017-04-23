REBOL [
title: "Diff directorie"
file: %diff-directories.r
date: 03/12/2010
author: "nicolas"
purpose: {
Give a directory in parameter, 
=> first launch return a block with the content of the directory
=> next launch, compare content of the directory with save data in a file named old-lst.txt and return new files and file that has changed
}
]

diff-directories: func [dir [file!] /date /full /local new-lst old-lst file diff diff-lst] [
	diff-lst: []
	new-lst: read dir
	forall new-lst [new-lst: back insert next new-lst get-modes dir/(new-lst/1) 'modification-date]
	old-lst: any [all [exists? fic: %old-lst.txt load fic] make block! 20]
	save %old-lst.txt new-lst
	if 0 < length? old-lst [
		if any [date full] [
			forskip new-lst 2 [
				file: pick new-lst 1
				new-date: select new-lst file
				old-date: select old-lst file
				if any [not new-date not old-date 0:00 < diff: difference new-date old-date][append diff-lst file]
			]
		]
	]	
	if not date [
		new-lst: extract new-lst 2
		either 0 < length? old-lst [
			old-lst: extract old-lst 2
			diff: difference new-lst old-lst
			append diff-lst diff
		][append diff-lst new-lst]
	]
	return copy diff-lst
]
