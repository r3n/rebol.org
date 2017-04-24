REBOL [
	Title: "Todo List"
	File: %todo-list.r
	Date: 24-Jun-2004/14:59:42+2:00
	Author: "Carl Sassenrath, Didier Cadieu & Fabrice Vado"
	Url: http://www.codeur.org/forum/message.php?sujet=1379&theme=17
	Purpose: {Based on the demo of Rebol /View by Carl. It allow you to manage a list of todo and move them between them.}
	Version: 1.3.0
    library: [
        level: 'intermediate
        platform: 'all
        type: [demo tool]
        domain: [database file-handling gui user-interface ]
        tested-under: [view 1.2.8.3.1 on "Windows XP Pro"]
        support: none
        license: none
        see-also: none
    ]
]

flash "Loading data..."
read-thru http://www.rebol.com/view/demos/todo-data.r
unview
todo-path: %todo-data.r

status-words:    [New Pend Now Wait Done Remind]
priority-levels: [1 2 3 4 5 6 7 8 9]
effort-words:    [Easy Medium Difficult]
category-words:  [Misc Design Code Doc Test]


;-- Utility functions:

fail: func [msg] [request/ok msg quit]


;-- Generate images for dot and arrows:

make-image: func [xy wh eff] [
	eff: layout [
		size 20x20 at xy
		box wh effect eff
	]
	eff/color: main-color
	to-image eff
]

dot: make-image 6x5 9x9 [gradient 1x1 255.0.0 0.0.0 oval key 0.0.0]
arr: make-image 3x3 14x14 [arrow 0.0.127 rotate 90]
ard: make-image 3x3 14x14 [arrow 0.0.127 rotate 180]


;-- Item creation, loading, and saving:

item-obj: context [
	summary:
	paritem:
	subitems:
	expanded:
	face:
	;items-block:
	notes: none
	priority: 5
	status: first status-words
	effort: first effort-words
	category: first category-words
]

make-item: func [
	"Given a block of todo items, return a block of todo item objects. Recursive."
	item-blk
	parent
	/local item items sum sub pri notes stat diff cat
][
	items: copy []
	foreach item item-blk [
		set [sum pri stat diff cat note sub] item
		item: make item-obj [
			summary: sum
			priority: pri
			status: stat
			effort: diff
			category: cat
			notes: note
			;items-block: items
			paritem: parent
		]
		if sub [item/subitems: make-item sub item]
		append items item
	]
	items
]

load-items: func [
	"Load a file of valid todo items. Return the top level block."
	file
][
	if not exists? file [return make-item [["Add some items!" 1 new easy test ""]] none]
	file: load/all file
	if file/1 = 'history [
		list-date/text: file/2/1
		show list-date
		file: skip file 2
	]
	make-item file none
]

emit-item: func [
	"Format a todo item for output to a file. Recurse over subitems."
	item out
	/local indent
][
	indent: ""
	repend out [indent "["]
	foreach word [summary priority status effort category notes] [
		append out mold item/:word
		append out " "
	]
	if item/subitems [
		append indent tab
		append out " [^/"
		foreach item item/subitems [emit-item item out]
		remove indent
		repend out [indent "]"]
	]
	append out "]^/"
]

save-items: func [
	"Save todo items to a file."
	items
	/local out
][
	out: make string! 10000
	repend out ["history [" now "]" newline newline]
	foreach item items [emit-item item out]
	write todo-path out
	list-date/text: now show list-date
]


;-- Item user interface:

selected-item: none
item-wide: 480
item-cnt: 0
list-date: none

main-window: layout [
	style button button 60
	across
	vh2 join "Todo List " system/script/header/version
	button "Save"   #"^s" [save-items todo-list]
	button "<" #"^o" [outdent-item]
	button ">" #"^i" [indent-item]
	button "^^" #"^l" [move-item/up]
	button "v" #"^r" [move-item/down]
	return
	space 0x8
	clip-box: box base-color / 2 480x400 edge [size: 0x1 color: coal]
	list-slide: slider 16x400 [scroll-box value] return
	space 8x8
	button "New"    #"^n" [new-item]
	button "Delete" #"^d" [del-item selected-item]
	txt 80x24 middle right bold "Updated:"
	list-date: text 240x24 middle center form now white base-color / 2
]

layout [select-box: box 480x22 orange]
select-box/offset: 0x-40

list-box: make-face 'box
list-box/size: clip-box/size
clip-box/pane: list-box
list-pane: list-box/pane: []

scroll-box: func [value] [
	list-box/offset/y: negate value * (list-box/size/y - clip-box/size/y)
	show list-box
]

select-item: func [item] [
	selected-item: item
	select-box/offset: item/face/offset - 1x1
	show select-box
]

select-action: func [face value] [
	select-item face/user-data
]

expand-action: func [face value] [
	; Expand subitem list.
	face/user-data/expanded: not face/user-data/expanded
	select-action face value
	refresh-list
]

make-item-face: func [
	"Create the GUI summary line for an item."
	item
	/local bx px tx sx pri
][
	pri: form any [item/priority 5]
	item/face: layout [
		origin 0 space 0 across
		bx: image dot
		px: text 20x20 pri snow leaf center middle font-size 11 [show-detail face]
		tx: field edge none 400x20 middle font-size 11
		sx: txt 50x20 black main-color middle center font-size 11 [show-detail face]
	]
	item/face/color: none
	bx/user-data: px/user-data: tx/user-data: sx/user-data: item
	bx/action: :select-action
	sx/text: item/status
	px/color: pick [200.0.0 220.120.0 120.120.0 120.180.0 0.160.0 0.130.150 0.60.160 0.0.140 80.0.100] to-integer pri
	sx/color: pick [160.160.160 220.40.40 220.220.40 60.60.240 40.140.60 180.154.100] index? find status-words item/status
	if item/subitems [
		bx/action: :expand-action
		bx/image: either item/expanded [ard][arr]
	]
	tx/text: item/summary
	item/face
]

locate-item-face: func [
	"Position a face and adjust the size of it."
	item
	where
	width
	/local face
][
	face: item/face
	face/offset: where
	face/size/x: item-wide
	face/pane/3/size/x: item-wide - where/x
	face/pane/4/offset/x: item-wide - where/x - 50
]

make-list: func [
	"Make a pane of item faces."
	items
	depth
][
	foreach item items [ ;print item/summary
		append list-pane make-item-face item
		locate-item-face item to-pair reduce [20 * depth + 1 item-cnt * 21 + 1]
		item-cnt: item-cnt + 1
		if item/expanded [make-list item/subitems depth + 1]
	]
	list-box/size/y: 1 + item-cnt * 21
	list-slide/redrag clip-box/size/y / list-box/size/y
]

refresh-list: does [
	clear list-pane
	item-cnt: 0
	insert list-pane select-box
	make-list todo-list 0
	show list-box
]

new-item: has [list item parent] [
	list: either selected-item [
		next find any [
			all [selected-item selected-item/paritem selected-item/paritem/subitems]
			todo-list
		] selected-item
	] [
		todo-list
	]
	parent: either none? list [none][either tail? list [back list][first list]]
	;if none? parent [parent: last list]
	insert list make item-obj [
		summary: copy "" ;items-block: list
		paritem: parent
	]
	refresh-list
	select-item item: first list
	focus item/face/pane/3
]

del-item: func [item] [
	if none? item [exit]
	item: either item/paritem [
		find item/paritem/subitems item
	] [
		find todo-list item
	]
	if item [remove item]
	hide select-box
	selected-item: none
	refresh-list
]

indent-item: has [list item] [
	if none? selected-item [exit]
	item: either selected-item/paritem [
		find selected-item/paritem/subitems selected-item
	] [
		find todo-list selected-item
	]
	par-item: first back item
	if par-item = selected-item [exit]
	remove item
	if none? par-item/subitems [par-item/subitems: copy []]
	par-item/expanded: true
	append par-item/subitems selected-item
	;selected-item/items-block: par-item/subitems
	selected-item/paritem: par-item
	refresh-list
	select-item selected-item
]

outdent-item: has [list item par-item old-par-item] [
	if any [none? selected-item none? old-par-item: selected-item/paritem] [exit]
;	if same? selected-item/items-block selected-item [print "same" exit]
	item: find old-par-item/subitems selected-item
	remove item
	list: either none? par-item: old-par-item/paritem [todo-list][par-item/subitems]
	item: find list old-par-item
	if found? item [item: next item]
	if any [none? old-par-item/subitems empty? old-par-item/subitems] [old-par-item/subitems: old-par-item/expanded: none]
	insert item selected-item
	;selected-item/items-block: list
	selected-item/paritem: par-item
	refresh-list
	select-item selected-item
]

move-item: func [
	"Move the selected item up or down"
	/up /down
	/local item
] [
	if any [none? selected-item] [exit]
	item: either all [selected-item/paritem selected-item/paritem/subitems] [
		find  selected-item/paritem/subitems selected-item
	] [
		find todo-list selected-item
	]
	if up [insert back remove item selected-item]
	if down [insert next remove item selected-item]
	refresh-list
	select-item selected-item
]

detail-view: layout [
	style tr txt bold right 70x24
	style fld field 400x24
	style ar area
	across
	tr "Item:"  fv-summary: fld bold
	return
	tr "Priority:"
	fv-priority: choice data priority-levels [this-item/priority: value]
	tr "Category:"
	fv-category: choice data category-words
	return
	tr "Status:"
	fv-status: choice data status-words [this-item/status: value]
	tr "Effort:"
	fv-effort: choice data effort-words
	return
;   tr "Who:"      fv-who: fld return
;   tr "Duration:" fv-duration: fld 150x24 return
	tr "Notes:"    fv-notes: ar wrap return
]

this-item: none

show-detail: func [face] [
	this-item: face/user-data
	fv-summary/data: fv-summary/text: copy this-item/summary
	fv-notes/data: fv-notes/text:
		copy either string? this-item/notes [this-item/notes][""]
	fv-notes/line-list: none
	fv-priority/text: first fv-priority/data: any [find priority-levels this-item/priority priority-levels]
	fv-status/text: first fv-status/data: any [find status-words this-item/status status-words]
	fv-category/text: first fv-category/data: any [find category-words this-item/category category-words]
	fv-effort/text: first fv-effort/data: any [find effort-words this-item/effort effort-words]
	inform detail-view
	this-item/summary: copy fv-summary/text
	this-item/priority: first fv-priority/data
	this-item/status: first fv-status/data
	this-item/category: first fv-category/data
	this-item/effort: first fv-effort/data
	this-item/notes: copy fv-notes/data
	refresh-list
]

center-face main-window none
todo-list: load-items todo-path
refresh-list
view main-window