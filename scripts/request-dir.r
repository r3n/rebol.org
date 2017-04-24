REBOL [
	file: %request-dir.r
	title: "Directory selector (treeview)"
	name:
	author: "Didier CADIEU"
	email: didec@wanadoo.fr
	date: 11-09-2003
	version: 1.0.0
	needs: {Work only on View 1.2.8+}
	purpose: {
		Open a requestor to select a directory.
		The current directories path is shown as a tree, and sub-dirs are shown for selection.
	}
	comment: {
		The make-dir button does not work as you can expect due to a bug in the management
		of modale window in view : the directory is created only when the function return.
		
		You can use the patch from Romano Paolo Tenca to correct this behaviour.
		
		This script is based on a work from Carl Sassenrath, found in the Mailing list
	}
	library: [
		level: 'advanced platform: 'all type: [module function] domain: [file-handling files ui vid]
		tested-under: "View 1.2.8 Win2K" license: 'public-domain support: "use email"
	]
]

ctx-req-dir: context [
	max-dirs:
	cnt: 0
	f-list:
	f-txt: 
	f-slid:
	f-path:
	path:
	last-path:
	result:
	dirs: none
	
	list-data: copy []
	links: [ [draw [pen 0.0.0 line 6x0 6x9 12x9]] [draw [pen 0.0.0 line 6x0 6x18 line 6x9 12x9]] ]
	lib: pth: lev: none
	dec: 11
	
	dirout: [
		origin 8x8 space 0x0
		vh3 "Select a directory"
		across pad 0x4
		f-list: list 300x292 180.180.180 [ 
			origin 0 space 0 across
			box 16x18
			f-txt: text 300 font-size 11 font [colors: [0.0.0 0.0.0]] [chg-dir face/user-data]
		] supply [
			count: count + cnt
			if count > length? list-data [face/show?: false exit]
			face/show?: true
			set [lib pth lev] pick list-data count
			either index = 1 [
				face/offset/x: lev - dec 
				face/effect: pick links not attempt [(third pick list-data count + 1) = lev]
			] [
				face/text: lib
				face/color: pick [240.240.240 220.220.220] odd? count
				face/offset/x: lev
				if path = face/user-data: pth [face/color: 255.190.80 250.150.150]
			]
		]
		
		f-slid: scroller 16x292 [
			c: to-integer value * ((length? list-data) - max-dirs)
			if c <> cnt [cnt: c show f-list]
		] return

		space 60x4
		f-path: field wrap font-size 11 316x40 [
			value: attempt [to-rebol-file to-file f-path/text]
			if all [value exists? value] [path: value show-dir]
		] return
		btn-enter 65 "Open" [result: dirize path hide-popup]
		btn 65 "Make Dir" [
			value: request-text/title "Directory name:"
			if value [
				trim value
				if not empty? value [
					either error? try [make-dir rejoin [dirize path value]] [
						alert "Cannot create directory."
						path: copy last-path
					] [chg-dir path]
				]
			]
		]
		btn-cancel 65 "Cancel" [hide-popup]
	]
	
	chg-dir: func [file][
		if none? file [exit]
		last-path: copy path
		path: copy file
		show-dir
	]

	; build a tree of dirs from first to last in the path, recursively
	build-tree: func [p /local b l] [
		b: split-path p
		l: 0
		if not none? second b [l: dec + build-tree first b]
		either b/2 [any [slash <> last b/2 remove back tail b/2]][change at b 2 "(root)"]
		append/only list-data reduce [any [second b "(root)"] p l]
		l
	]
	
	show-dir: has [l d] [
		; read contents of path
		dirs: attempt [load dirize path]
		if not dirs [
			path: last-path
			if not dirs: attempt [load dirize path][
				alert reform ["Invalid directory:" path]
				dirs: load path: %/
			]
		]
		; keep only sub-dirs
		remove-each file dirs [slash <> last file]
		clear list-data
		; recontruct the tree for the path
		l: dec + build-tree path
		; append the sub-dirs
		foreach file sort dirs [
			replace/all file #"/" ""
			append/only list-data reduce [file rejoin [dirize path file] l]
		]
		; show everything
		f-path/text: any [attempt [to-local-file path] copy ""]
		f-slid/redrag max-dirs / max 1 length? list-data
		f-slid/step: either 0 >= d: (length? list-data) - max-dirs [0][1 / d]
		f-slid/data: 0.0
		cnt: 0
		show [f-list f-slid f-path]
	]

	set 'request-dir func [
		"Requests a directory using pseudo treeview."
		/keep "Keep previous directory path"
		/dir "Set starting directory" where [file!]
		/offset xy /local
	][
		if block? dirout [
			dirout: layout dirout
			max-dirs: to-integer f-list/size/y - 4 / f-txt/size/y
			center-face dirout
		]
		if not all [keep path] [path: any [where what-dir]]
		if all [not empty? path slash = last path][remove back tail path]
		last-path: path
		result: none
		show-dir
		either offset [inform/offset dirout xy][inform dirout]
		result
	]
]

;request-dir
