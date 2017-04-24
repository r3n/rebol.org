REBOL [
    Title: "Autoextracting REBOL file creator"
    Date: 16-Jun-1999
    File: %autoextract.r
    Author: "Bohdan Lechnowsky"
    Purpose: {Send files via email which can be decompressed simply by executing the contents of the message when it is received.}
    Email: bo@rebol.com
    library: [
        level: 'intermediate 
        platform: none 
        type: 'function 
        domain: [email file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

autoextract: func [
    {Compresses a file and puts it into a script 
     which will automatically extract itself}
    infile  [file!] {Name of file to compress}
    outfile [file!] {Name to save compressed file}
][
    file: enbase/base compress read/binary infile 64
    infile: to-file last parse infile "/"

    output: [{Self-extracting REBOL-compressed file
        REBOL [
            Title:  "Self-extracting compressed file"
            Date:  } now {
            File:  } mold infile {
            Author:  "Autoextract function by Bohdan Lechnowsky"
            Comment:  ^{
               Simply run this script and it will 
               decompress and save the file for you
            ^}
        ]

        if exists? } mold infile { [
            print ["} infile { already exists, please rename"
                           " existing file and run again."]
            halt
        ]
        write } mold infile { decompress 64#} mold file
    ]
    write outfile to-string reduce output
]
