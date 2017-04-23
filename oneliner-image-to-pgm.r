REBOL [
    Title: "Image to pgm converter"
    Date: 19-Jan-2013
    File: %oneliner-image-to-pgm.r
    Purpose: "Creates a binary Portable Graymap (PGM - P5) from an image! source"
    Version: 1.0.0
    Author: "Vincent Ecuyer"
    Usage: {
        to-pgm 
            value (image!)
            channel ('r, 'g, or 'b)
			
        alpha-to-pgm
            value (image!)
	
        ==REBOL2
        write/binary %imageTest-red.pgm   to-pgm logo.gif 'r
        write/binary %imageTest-green.pgm to-pgm logo.gif 'g
        write/binary %imageTest-blue.pgm  to-pgm logo.gif 'b
		
        write/binary %imageTest-alpha.pgm alpha-to-pgm logo.gif		

        ==REBOL3
        write %imageTest.pgm to-pgm make image! [320x256 127.0.0] 'r
    }
    Comment: {
        The result is in PGM P5 (binary) format, compatible with Gimp, Netpbm tools, and other
        image processing packages. The 'alpha-to-pgm function can be used with 'to-ppm to save 
        the transparency/alpha channel (as there is no alpha information in a .ppm file).
    }
    Library: [
        level: 'intermediate
        platform: 'all
        type: [tool one-liner function]
        domain: [graphics]
        tested-under: [
            view 2.7.8.3.1 on [Windows win32-x86]
            core 2.101.0.2.5 on [Macintosh osx-x86]
        ]
        support: none
        license: 'public-domain
        see-also: %oneliner-image-to-ppm.r
    ]
]
to-pgm: func [value [image!] channel [word!]] [join #{} ["P5 " replace form value/size "x" " " " 255^(0A)" extract/index value/rgb 3 index? find [r g b] channel]]

alpha-to-pgm: func [value [image!]] [join #{} ["P5 " replace form value/size "x" " " " 255^(0A)" value/alpha]]
