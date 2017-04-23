REBOL [
    Title: "Posterize" 
    Date: 31-Jan-2013 
    File: %oneliner-posterize.r 
    Purpose: "A short function for 'posterization' effects on images" 
    Version: 1.0.0 
    Author: "Vincent Ecuyer" 
    Usage: {
        'posterize applies a type of color reduction on images, ignoring
        the less significative bits of each color channel, the result
        having flat colors zones instead of gradual transitions.
    
        result: posterize value (image!) depth (integer!)
        
        where depth is between 1 and 7, with 1 keeping only 8 colors,
        and 7 with the less noticeable effect.

        The result is darker so a brightness correction would be appropriate:
        for the strongest setting, with depth = 1 (-> 8 colors), half the 
        brightness is lost, so applying a VID 'effect like “multiply 255” would 
        do the trick.
        
        ; save a posterized version of a picture
        save/png %img-dest.png posterize load %img-src.png 3
        
        ; directly used in a display
        view layout [image posterize load http://www.rebol.com/view/demos/nyc.jpg 1 effect [multiply 255]]
    }
    Comment: {
        depth = 0 or less gives a black result (0 bit/color channel),
        depth = 8 does nothing (8 bits/color channel as the original),
        but depth > 8 gives a false color effect 
            (but darker so one should compensate with 'multiply or similar)
    }
    Library: [ 
        level: 'intermediate 
        platform: 'all 
        type: [tool one-liner function] 
        domain: [graphics] 
        tested-under: [ 
            view 2.7.8.2.5 on [Macintosh osx-x86] 
        ] 
        support: none 
        license: 'public-domain 
        see-also: none 
    ]
]

posterize: func [value [image!] depth [integer!] /local t][value and make image! reduce [value/size 255.255.255 / (t: 2 ** (8 - depth)) * t]]
