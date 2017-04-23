REBOL [
	file:		%adalogo.r
	title:		"A.D.A. Logo Viewer"
	author:		"Semseddin (Endo) Moldibi"
	version:	1.0.0
	date:		2011-07-25
	purpose:	"Amiga Demoscene Archive - Logo Viewer"
	Library: [
		level: 'beginner
		platform: 'all
		type: 'one-liner
		domain: 'graphics
		tested-under: [view 2.7.8.3.1 on "WinXP Pro"]
		support: none
		license: 'public-domain
		see-also: none
	]
]

random/seed now view layout [text "Click!" origin 0x0 img: image 320x256 [img/image: load rejoin [http://ada.untergrund.net/logos/logo_ random 134 %.png] show img]]
