REBOL [
    Title: "Blit-r"
    Date: 17-Jan-2013
    Version: 1.0.0
    File: %blit.r
    Author: "Vincent Ecuyer"
    Purpose: {A simple 16 modes blitter function}
    Usage: {
        This 'blit function simulates a simple 16 modes blitter:

            blit destination brush mask op-mode
        
        performs the following logical operation on the destination image:
        
            (brush and mask) op-mode (destination and not mask)

        Where brush is:
            image! : an image smaller or of the same size that destination
            block! : a VID effect block in this format [size _pair!_ _effects sequence_]
                        (example: [size 100x100 emboss colorize 255.0.255])
        Mask is:
            none : no mask
            tuple! : bitplanes selection 
                     (red (or 255.0.0) = red only, white (or 255.255.255) = red + green + blue)
            image! : a mask to applies (M and ...) to the brush and destination
            block! : for faster operation, an image! and its precalculated complement 
                     (negative) in a block

        and Op-Mode is: 
            (integer! or word!)
            0000 -  0 - 'clear        : clears destination (fills with black)
            0001 -  1 - 'nor          : brush nor destination 
            0010 -  2 - 'not-but      : not brush but destination
            0011 -  3 - 'invert-brush : not brush
            0100 -  4 - 'but-not      : brush but not destination
            0101 -  5 - 'invert       : not destination
            0110 -  6 - 'xor          : brush <> destination
            0111 -  7 - 'nand         : brush nand destination
            1000 -  8 - 'and          : brush and destination
            1001 -  9 - 'iff          : brush <=> destination
            1010 - 10 - 'none         : destination
            1011 - 11 - 'imp          : brush => destination
            1100 - 12 - 'replace      : brush
            1101 - 13 - 'if           : brush <= destination
            1110 - 14 - 'or           : brush or destination
            1111 - 15 - 'fill         : fills destination (fills with white)
    }
    Library: [
        level: 'advanced
        platform: 'all
        type: [demo function]
        domain: [graphics]
        tested-under: [
            	view 2.7.8.2.5 on [Macintosh osx-x86]
        ]
        support: none
        license: 'apache-v2.0
        see-also: none
    ]
]

blit: func [
    "Apply a blitter operation to an image. Returns saved area."
    image [image!] "Image to modify"
    brush [image! block!] "Brush or effect"
    mask [image! tuple! block! none!] "Mask, bitplanes or block of mask / not mask"
    mode [word! integer!] "Blitter mode: 0 to 15 or op name"
    /restore area [block! none!] "Restore a previous saved area."
    /local n
][
    all [restore area foreach [offset data] area [change at head image offset data]]
    mode: either word? mode [
        index? find [
            clear nor not-but invert-brush but-not invert xor nand
            and iff none imp replace if or fill
        ] mode
    ][mode + 1]
    area: copy/part image brush/size
    mask: switch type?/word mask [
        tuple! [reduce [
            make image! reduce [brush/size mask]
            make image! reduce [brush/size 255.255.255 xor mask 255]
        ]]
        image! [reduce [
            mask
            mask xor make image! reduce [brush/size 255.255.255]
        ]]
        none! [reduce [
            make image! reduce [brush/size 255.255.255 255]
            make image! reduce [brush/size 0.0.0]
        ]]
        block! [mask]
    ]
    if block? brush [
        layout compose [brush: image (area) effect next next brush]
        brush: to-image brush
    ]
    change image do pick [
        [; 0 clear
            mask/2 and area
        ][; 1 nor
            (brush xor n: make image! reduce [brush/size 255.255.255]) and (area xor n) and mask/1 or (mask/2 and area)
        ][; 2 not-but
            brush xor mask/1 and area and mask/1 or (mask/2 and area)
        ][; 3 invert-brush
            brush xor mask/1 and mask/1 or (mask/2 and area)
        ][; 4 but-not
            area xor mask/1 and brush and mask/1 or (mask/2 and area)
        ][; 5 invert
            mask/1 xor area
        ][; 6 xor
            brush and mask/1 xor area
        ][; 7 nand
            brush xor mask/1 and mask/1 or (mask/1 xor area)
        ][; 8 and
            brush or mask/2 and area
        ][; 9 iff
            (brush xor make image! reduce [brush/size 255.255.255]) and mask/1 xor area
        ][; 10 none
            area
        ][; 11 imp
            brush xor mask/1 and mask/1 or area
        ][; 12 replace
            brush and mask/1 or (mask/2 and area)
        ][; 13 if
            brush and mask/1 or (mask/1 xor area)
        ][; 14 or
            brush and mask/1 or area
        ][; 15 fill
            mask/1 or area
        ]
    ] mode
    reduce [index? image area]
]

;Demo: right-click to change mode
blit-demo: does [
    ;Base image
    img: load http://www.rebol.com/view/demos/nyc.jpg
    
    ;Brush creation
    img3: copy/part img2: copy img 100x100
    
    ;Mask creation
    layout [i: box img3/size white effect [oval]]
    i: to-image i
    i: reduce [i i xor make image! reduce [i/size 255.255.255]]
    
    s: none
    mode: 0
    view layout [
        backcolor rebolor
        image img2 rate 5 feel [
            engage: func [f a e][
                if find [over down] a [
                    s: blit/restore
                        skip img2 img3/size / -2 + e/offset
                        img3 
                        i 
                        mode 
                        s
                    show f
                ]
                if a = 'alt-down [
                    mode: mode + 1 // 16
                    mode-name/text: pick [
                        "0 clear" "1 brush nor image" "2 not-but" "3 invert brush"
                        "4 but-not" "5 invert image" "6 brush xor image" "7 brush nand image"
                        "8 brush and image" "9 brush <=> image" "10 none" "11 brush => image"
                        "12 replace" "13 image => brush" "14 brush or image" "15 fill"
                    ] mode + 1
                    show mode-name
                ]
            ]
        ]
        across vtext "Effect: " mode-name: vtext 200 "0 clear"
    ]
]