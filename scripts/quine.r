REBOL [
    Title: "Quine"
    Date: 20-Nov-2001/11:55:36+13:00
    Version: 1.0.0
    File: %quine.r
    Author: "J.S. Labuschagne"
    Purpose: {A Rebol quine; a program which reproduces its own code.}
    Email: curve@waveform.org
    Description: "Rebol quine"
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: 'x-file 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
quine: func [][
    print join "REBOL[^/"
    join "    Author:      {J.S. Labuschagne}^/"
    join "    Description: {Rebol quine}^/"
    join "]^/quine: "
    join mold :quine "^/quine"
]
quine
                   