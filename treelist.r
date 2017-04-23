REBOL [
	title: "(treelist)"
	file: %treelist.r
	author: "Marco Antoniazzi derived from Didier CADIEU"
	email: [luce80 AT libero DOT it]
	date: 16-05-2010
	version: 0.0.1
	needs: {Works only on View 1.2.8+}
	comment: { a simple tree-view}
	Purpose: "show how to build a simple tree list"
	Category: [util vid view]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'how-to
		domain: [gui vid]
		tested-under: [View 2.7.6.3.1]
		support: none
		license: 'BSD
		see-also: none
	]
]

max-rows:
cnt: 0
indent: 12

tree-leaf: 0 tree-opened-node: 1 tree-closed-node: -1
tree-data: [[1 0 root][-1 1 numbers][0 2 "one"][0 2 "two"][-1 2 fruits][0 3 "apple"][0 3 "banana"][0 2 "three"][1 1 names][0 2 "a"][0 2 "b"]
[1 1 numbers][0 2 "101"][0 2 "102"][-1 2 "103"][0 3 "103.1"][0 3 "103.2"][0 2 "104"]]
triangle: [pen none fill-pen blue polygon 8x0 8x8 0x8]
bullets: compose/deep/only [
	[draw (append [translate -1 10 rotate -45] triangle) ]
	[draw [pen none fill-pen black circle 6x10 3]]
	[draw (append [translate 2 6] triangle) ]
]

total_visible: func [/current cur /local visible-count closed-level tree-line curr] [
	curr: 0
	visible-count: 0
	closed-level: 1000
	foreach tree-line tree-data [
		set [opened level line-text] tree-line
		if all[(opened = tree-closed-node) (level < closed-level)] [closed-level: level]
		if all[(opened = tree-opened-node) (level <= closed-level)] [closed-level: 1000]
		if level <= closed-level [visible-count: visible-count + 1]
		if /current [
			curr: curr + 1
			if equal? visible-count cur [visible-count: curr break]
		]
	]
	;print [visible-count]
	visible-count
]

tree-layout: [
	origin 8x8 space 0x0
	across pad 0x4
	tree-list: list 150x0 + (1x18 * 0x6) + 0x8 [ 
		origin 0 space 0 across
		box (indent * 1x0 + 0x18) with [opened: -2]
		tree-line-txt: text 150x18 black 240.240.240 font [colors: [0.0.0 250.0.0] size: 11] with [opened: -1] [switch_fold face]
	] supply [
		level: line-text: none
		face/opened: total_visible/current count + cnt
		if count > face/opened [face/show?: false exit]
		face/show?: true
		either index = 1 [
			face/offset/x: level * indent
			face/effect: pick bullets opened + 2
		] [
			face/offset/x: level * indent + indent
			face/text: line-text
		]
	] effect reduce ['grid (indent * 1x0) 0x0 220.220.220]
	
	tree-scroller: scroller tree-list/size * 0x1 + 16x0 [
		value: max 0 to-integer value * (max-rows - visible-rows)
		if value <> cnt [cnt: value show tree-list]
	] return
	btn "Fold all" [fold_all] btn "Unfold all" [unfold_all]
]

resize_scroller: func [sld [object!] tot-rows [integer!] visible-rows [integer!]] [
	either visible-rows >= tot-rows [
		sld/step: 0
		sld/redrag 1
		sld/data: 0.0
		cnt: 0
		;sld/show?: false
	][
		sld/step: 1 / (tot-rows - visible-rows)
		sld/redrag (max 1 visible-rows) / tot-rows
		cnt: to-integer sld/data * (tot-rows - visible-rows)
		;sld/show?: true
	]
]

switch_fold: func [face /local tree-line][
	tree-line: pick tree-data face/opened
	tree-line/1: negate tree-line/1
	resize_scroller tree-scroller max-rows: total_visible visible-rows
	show [tree-scroller tree-list ]
]

fold_all: func [/local tree-line][
	foreach tree-line tree-data [if tree-line/1 <> 0 [tree-line/1: -1]]
	resize_scroller tree-scroller max-rows: total_visible visible-rows
	show [tree-scroller tree-list ]
]

unfold_all: func [/local tree-line][
	foreach tree-line tree-data [if tree-line/1 <> 0 [tree-line/1: 1]]
	resize_scroller tree-scroller max-rows: total_visible visible-rows
	show [tree-scroller tree-list ]
]

if block? tree-layout [
	tree-layout: layout tree-layout
	visible-rows: to-integer tree-list/size/y - 4 / tree-line-txt/size/y
	resize_scroller tree-scroller max-rows: total_visible visible-rows
]

view center-face tree-layout
