REBOL [
    Title: "Include Files"
    Date: 5-Nov-1997
    File: %include.r
    Purpose: {
        A useful function for "including" a single file
        or a block of files.  Web and other file paths
        are allowed.
    }
    Comment: {
        Notice that the included files are executed,
        which allows their words to be defined,
        functions created, include yet other files,
        etc.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

include: func [files] [
    either block? files [
        forall files [do first files]
    ] [
        do files
    ]
]

include %simple.r

include [
    %preface.r
    %headfull.r
    http://www.rebol.com/rebex/more.r
]
