REBOL [ 
File: %epu.r
Date: 6-Jun-2008
Title: "EPU" ;Epson Printer Utilities
Author: "AllRebbedUp"
Comment: {I would not have done this without the assistance of reboltalk forum members notchent & btiffin}
Purpose: {Simple GUI for accessing escputil on linux}
library: [
     level: 'intermediate
     platform: 'linux
     type: 'tool
     domain: 'gui
     tested-under: [view 2.7.6 on linux]
     support: none
     license: public-domain
     see-also: none
    ]
]

img: load 64#{
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
AAAASUVORK5CYII=
}

view layout/size [
		backdrop effect [gradient 0x1 0.0.0 127.127.127]
		vh2 "Epson Printer Utilities" 320x20 center effect [gradient 1x1 255.0.0 0.0.255]
		across	
		pad 0x170	
		button "Ink Levels" [
				call/output "escputil -iur /dev/usb/lp0" inks: make string! 512
				parse inks [
				thru "Black" copy black-ink to newline
				thru "Cyan" copy cyan-ink to newline
				thru "Magenta" copy magenta-ink to newline
				thru "Yellow" copy yellow-ink to newline
				]
				prog1/data: (to integer! trim/all black-ink) / 100
				show prog1
				box1/text: (to integer! trim/all black-ink)
				show box1
				prog2/data: (to integer! trim/all cyan-ink) / 100
				show prog2
				box2/text: (to integer! trim/all cyan-ink)
				show box2
				prog3/data: (to integer! trim/all magenta-ink) / 100
				show prog3
				box3/text: (to integer! trim/all magenta-ink)
				show box3
				prog4/data: (to integer! trim/all yellow-ink) / 100
				show prog4
				box4/text: (to integer! trim/all yellow-ink)
				show box4
				]
		button "Clean Heads" [call ["escputil -cur /dev/usb/lp0"]]
		button "Test Pattern" [call ["escputil -nur /dev/usb/lp0"]]
		at 95x75 image img effect [emboss]
		at 50x75 prog1: progress gray black 20x100 with [data: 0.00]
		at 48x185 box1: box 24x24 "" font-size 12
		at 230x75 prog2: progress gray cyan 20x100 with [data: 0.00]
		at 228x185 box2: box 24x24 "" font-size 12
		at 270x75 prog3: progress gray magenta 20x100 with [data: 0.00]
		at 268x185 box3: box 24x24 "" font-size 12
		at 310x75 prog4: progress gray yellow 20x100 with [data: 0.00]	
		at 308x185 box4: box 24x24 "" font-size 12	
] 360x270





