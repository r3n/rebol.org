REBOL [
    Title: "CopyCon"
    Date: 25-Aug-2001
    Version: 1.0.0
    File: %copycon.r
    Author: "ND"
    Purpose: {Inline Line-Editor for Rebol Console mode, you can extent by loading/saving/exeucting the buffer}
    Email: none
    library: [
        level: 'intermediate 
        platform: 'all
        type: 'tool 
        domain: 'x-file 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


edit: func [ {Inline-editor for rebol console "Copy Con" }
    /local old_history
][
    print "*** Text is placed in editbuf! press (Escape to quit) ***"
    old_history: system/console/history
    system/console/history: []
    error? try [ editbuf: read console:// ] 
    system/console/history: old_history
    unset 'old_history
]

                       