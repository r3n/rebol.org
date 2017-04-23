REBOL [
    Title: "Email Files as Compressed"
    Date: 10-Sep-1999
    File: %mailfilescomp.r
    Purpose: {
        This example sends a group of files (binary
        or text) as a single compressed text message.
    }
    Note: {
        Sends the decompression script as well.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [email file-handling other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

directory: %.      ; where to find the files
pattern: %mail*.r  ; a pattern to match particular files

system/options/binary-base: 64  ; best binary encoding

message: reform ["Files from directory" directory {
REBOL [Date:} now {]

files: [
}]

foreach file read directory [
    if find/match/any file pattern [
        append message reduce [
            "%" file " " compress read/binary file newline
        ]
    ]
]

append message {]

foreach [file data] files [
    write/binary file decompress data
]
}

send luke@rebol.com message
