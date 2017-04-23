REBOL [
    Title: "Test double-click"
    Date: 16-Feb-2006
    File: %double-clic.r
    Author: "Ph. Le Goff" 
    Email:  lp.legoff@free.fr
    Version: 0.0.1
    Purpose: "An example of double-click testing"
    History: ["16-Feb-2006 - Initial" ]
    Purpose: {
        View testing
    }
    library: [
        level:    'beginner
        platform: 'windows
        type:     [demo how-to]
        domain:   [VID]
        tested-under: [view 1.3.2 on WXP]
        support:  none
        license:  none
        see-also: none
    ]
]

{usage: just double-clic on green box, event/8 is true if system detects a double-click}

fen: layout [
bx: box "double-click me ! " green feel [
	engage: func [f a e] [  
		if e/8  [ 
			bx/color: random 255.255.255
			show f
		] 
	] ; engage
      ] 
] ; end fen


view center-face fen
