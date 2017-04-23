REBOL [
    Title:  "Scrolling LIST Example"
    File:   %list-scroll-demo.r
    Author: "Gregg Irwin"
    Date:   16-Nov-2004
    Purpose: {
        Shows an example of how to use a LIST style face with
        an associated scroller.
    }
    library: [
        level:    'beginner
        platform: 'all
        type:     [FAQ how-to]
        domain:   [VID]
        tested-under: [view 1.2.8.3.1 on W2K]
        support:  none
        license:  none
        see-also: none
    ]
]

main-lst: sld: ; The list and slider faces
c-1:           ; A face we use for some sizing calculations
    none
ml-cnt:        ; Used to track the result list slider value.
visible-rows:  ; How many result items are visible at one time.
    0

; Generate some random data to put in the list
items: make block! 400
repeat i 400 [
    append/only items reduce [
        i random "ACBD" random 1000 random "AGCT"
    ]
]


lay: layout [
    origin 5x5
    space 1x0
    across

	style col-hdr text 50 center black mint - 20
    col-hdr "C1"  col-hdr "C2"  col-hdr "C3"  col-hdr "C4"
    return
    pad -2x0
    ; The first block for a LIST specifies the sub-layout of a "row",
    ; which can be any valid layout, not just a simple "line" of data.
    ; The SUPPLY block for a list is the code that gets called to display
    ; data, in this case as the list is scrolled. Here COUNT tells us
    ; which ~visible~ row data is being requested for. We add that to the
    ; offset (ML-CNT) set as the slider is moved. INDEX tells us which
    ; ~face~ in the sub-layout the data is going to.
    ; COUNT is defined in the list style itself, as a local variable in 
    ; the 'pane function.
	main-lst: list 207x300 [
 		across space 1x0 origin 0x0
        style cell text 50x20 black mint + 25 center middle
        c-1: cell cell cell cell
 	] supply [
        count: count + ml-cnt
        item: pick items count
        face/text: either item [pick item index][none]
 	]
	sld: scroller 16x300 [ ; use SLIDER for older versions of View
		if ml-cnt <> (val: to-integer value * subtract length? items visible-rows) [
			ml-cnt: val
			show main-lst
		]
	]
]

visible-rows: to integer! (main-lst/size/y / c-1/size/y)

; Original code to set thumb and step size:
; ; REDRAG sets the size of the thumb/dragger and the paging step size.
; sld/redrag divide visible-rows max 1 length? items
; ; Set the arrow and page step sizes to what *we* want them to be.
; sld/step: max .001 divide 1 max 1 length? items
; Per Ladslav's suggestion, it is now this:
either visible-rows >= length? items [
    sld/step: 0
    sld/redrag 1
][
    sld/step: 1 / ((length? items) - visible-rows)
    sld/redrag (max 1 visible-rows) / length? items
]
; I'm leaving the original code in the script for comparison purposes.

; We don't need to set the page size here if we've set a good value
; in REDRAG. If we don't use REDRAG correctly, the page step size
; will be off as well. i.e. You need to do one or the other.
;sld/page: sld/step * visible-rows

view lay

quit