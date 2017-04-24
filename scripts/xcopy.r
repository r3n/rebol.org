REBOL [
    Title: "xCopy"
    Date: 05-apr-06
    Version: 1.0
    File: %xcopy.r
    Author: "Christophe 'REBOLtof' Coussement"
    Email: "reboltof-at-yahoo-dot-com"
    Purpose: {
        REBOL implementation of the well-known xcopy tool.
        xcopy allows you to copy in one move files, directories, 
        subdirectories and contained files to a given location.
    }
    usage: {
        *** basic use ***
        
        >> do %xcopy.r
        
        >> xcopy %origin-file.r %target-file.r
        >> xcopy %origin-dir/ %target-dir/
        >> xcopy %origin-file.r %target-dir/
        
        *** refinements ***
        
        - use /verbose refinement to get some feedback on the actions
        >> xcopy/verbose %origin-dir/ %target-dir/
        
        - use /no-warn refinement if you do not want confirmation for overwriting
        >> xcopy/no-warn %origin-dir/ %target-dir/
        
        - use /filter to restrict copy to the file of the specified extension(s)
        caution: the extensions must be placed into a block!
        >> xcopy/filter %origin-dir/ %target-dir/ [%.r %.bmp] ; will only copy *.r and *.bmp files
        
        - and of course, use any combination of those refinements
        >> xcopy/filter/no-warn/verbose %origin-dir/ %target-dir/ [%.r %.bmp]
    }
    History: [
        "05-avr-2006 initial version"
    ]
    library: [
        level: 'intermediate 
        platform: all 
        type: [tool] 
        domain: 'file-handling 
        tested-under: [View 1.3.2.3.1 on "Windows XP"] 
        support: none 
        license: none 
        see-also: none
    ]
]

xcopy: func [
    origin [file!] 
    target [file!]
    /verbose
    /no-warn
    /filter suffix [block!]
][
    all [not value? 'root-dir root-dir: origin]
    all [not value? 'vbs vbs: verbose] 
    all [not value? 'warn warn: not no-warn]
    dir?: func [path][return #"/" = last form path]
    check-dir: func [dir][
        if not exists? dir [
           make-dir/deep dir 
           if vbs [print reform ["Created" dir]]
       ]
    ]
    no-write: func [path] [
        any [
            all [
               warn
               exists? path
               not request/confirm reform [
                   "This folder already contains a file named '" 
                   path
                   "'. Would you like to replace it ?"
               ]
            ] 
            all [
                filter
                not find suffix suffix? path
            ]
        ] 
    ]
    if not dir? origin [       
       if dir? target [
           check-dir target 
           target: join target last split-path origin
       ]
       if no-write target [return]
       write target read origin
       if vbs [print reform ["Copied" target]]
       return
    ]
    foreach elem read origin [
       new-dir: replace origin/:elem root-dir target
       either dir? elem [
           check-dir new-dir 
           xcopy origin/:elem target 
       ] [
           new-dir: replace origin/:elem root-dir target
           check-dir first split-path new-dir
           catch [
               if no-write new-dir [throw]
               write new-dir read origin/:elem
               if vbs [print reform ["Copied" new-dir]]
           ]
        ]
    ]
]