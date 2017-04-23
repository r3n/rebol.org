REBOL [
    Title: "Common Dir"
    Date: 3-Jul-2002
    Name: 'Common-Dir
    Version: 1.0.0
    File: %common-dir.r
    Author: "Andrew Martin"
    Purpose: "Common directory manipulation functions."
    Email: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

CD: :change-dir
LD: :list-dir
MD: :make-dir
WD: :what-dir

Directory?: func [File [file!]] [#"/" = last File]

Directory: function [File [file!]] [Subdirectories] [
    Subdirectories: parse/all File "/"
    if 1 < length? Subdirectories [
        append make file! copy/part Subdirectories -1 + length? Subdirectories #"/"
        ]
    ]

Filename: function [File [file!]] [Index] [
    copy/part File: to-file last parse/all File "/" find/last File %.
    ]

Extension?: func [File [file!]] [
    find/last File %.
    ]

Extension: function [File [file!] Ext [file!]] [Index] [
    join either found? Index: Extension? File [
        copy/part File Index
        ] [
        File
        ] Ext
    ]
                                          