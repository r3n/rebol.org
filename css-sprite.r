#!/usr/local/bin/rebview -qvs
REBOL [
	Title: "CSS Sprite creator"
	Author: onetom@hackerspace.sg
	Date: 2011-02-20
	File: %css-sprite.r
]

types: [%*.gif %*.png]   sprite: %sprite.png   test: %sprite.html  spacing: 0x1
name: func[f][ rejoin ["sprite-" head clear find copy f suffix? f]]
files: remove-each f read %. [f = sprite or not any map-each t types [find/any f t]]
montage: collect [ foreach f files [keep 'image keep f] ]
save/png sprite to-image layout/tight compose [
	backdrop 255.255.255.255 space spacing pad 0x0 (montage)]
offset: 0x0
css: map-each f files [
	i: load-image f   class: name f
	rule: rejoin [
		"."class" {width: "i/size/x"px; height: "i/size/y"px; "
	  "background: transparent url("sprite") 0 "offset/y"px no-repeat;}" lf
  ]  offset: offset - i/size - spacing
  rule
]

sprites: map-each f files [	reform [build-tag [div class (name f)] </div>] ]
images: map-each f files [ build-tag [img src (f)] ]
write test reduce [
	<html>
	<head>
		<style>
;	personal debug
;			"body {background: url(http://onetom.posterous.com/themes/back_to_school/bg.jpg)}" lf
;			"div, img {border: solid 1px red}" lf
			"body {background: grey}" lf
			"div, img {float: left}" lf
			css
		</style>
	</head>
	<body>
		<div>Sprites:</div> sprites
		<div>Images:</div> images
	</body>
	</html>
]
