REBOL [
    Title: "Image to ppm converter"
    Date: 17-Jan-2013
    File: %oneliner-image-to-ppm.r
    Purpose: "Creates a binary Portable Pixel Map (PPM - P6) from an image! source"
    One-liner-length: 98
    Version: 1.0.0
    Author: "Vincent Ecuyer"
    Usage: {
        ==REBOL2
        write/binary %imageTest.ppm to-ppm make image! [320x256 255.0.0]

        ==REBOL3
        write %imageTest.ppm to-ppm make image! [320x256 255.0.0]
    }
    Comment: {
        The result is in PPM P6 (binary) format, compatible with Gimp, Netpbm tools, and other
        image processing packages.
    }
    Library: [
        level: 'intermediate
        platform: 'all
        type: [tool one-liner function]
        domain: [graphics]
        tested-under: [
            view 2.7.8.2.5 on [Macintosh osx-x86]
            core 2.101.0.2.5 on [Macintosh osx-x86]
        ]
        support: none
        license: 'public-domain
        see-also: none
    ]
]
to-ppm: func [value [image!]] [join #{} ["P6 " replace form value/size "x" " " " 255^(0A)" value/rgb]]