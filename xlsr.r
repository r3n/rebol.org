REBOL [
    Title: "X ls -R"
    Date: 30-Jul-2002
    Version: 1.0.1
    File: %xlsr.r
    Author: "Gregory Pecheret"
    Purpose: {Provide a template to exectute a function on all files found recursively from a directory}
    Email: gregory.pecheret@free.fr
    library: [
        level: none 
        platform: none 
        type: [Tool function] 
        domain: [files file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


xlsr!: make object! [

        ; use this field to set a filter on extension ("java", "cpp", "png", ...)
    extension: none
        ; default methode to rewrite unless you just want to do what it does
    execute: func [f [file!]] [print f]

    scan-files: func [directory [file!] /local scan-result scan-elt is-dir] [
            either error? try [scan-result: read directory] [
                print rejoin ["problem reading directory " directory]
            ] [
                foreach scan-elt scan-result [
                    is-dir: false
                    if error? try [
                        is-dir: dir? to-file rejoin[directory scan-elt]
                    ] [
                        print rejoin ["problem testing " directory scan-elt]
                    ]
                    either is-dir [
                        scan-files rejoin [directory scan-elt]
                    ] [
                        if any [not extension extension = last parse/all scan-elt "."] [
                            execute rejoin [directory scan-elt]
                        ]
                    ]
                ]
            ]
    ]
]

{
; simple sample
xlsr!/scan-files %..

; sample to print java files
print-java: make xlsr! [
  extension: "java"
  execute: func [f [file!]] [print read f]
]

print-java/scan-files %.
}
                                                      