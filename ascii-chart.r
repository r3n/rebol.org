REBOL [
    Title: "ASCII Chart"
    Date: 10-october-2003
    Version: 1.0.0
    File: %ascii-chart.r
    Author: "Sunanda"
    Purpose: "Displays an ASCII chart"
    library: [
        level: 'beginner
        platform: [all plugin]
        type: 'demo
        domain: 'text
        plugin: [size: 640x640]
        tested-under: none
        support: none
        license: pd
        see-also: "ascii-info.r"
    ]
]

hex-lo: copy [across banner "ASCII Chart" return box 25x25 red "\"]
hex-chars: "0123456789ABCDEF"

for n 1 16 1
	[ append hex-lo [box 25x25 green]
	  append hex-lo form hex-chars/:n
	 ]
append hex-lo 'return

for hn 0 15 1
	[ append hex-lo [box 25x25 green]
		append hex-lo form pick hex-chars (hn + 1)
	  for ln 0 15 1
		[append hex-lo [box 25x25 blue]
		 append hex-lo form (to-char 16 * hn + ln)
		]
		 append hex-lo 'return
	]

unview/all
view layout hex-lo