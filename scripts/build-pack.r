REBOL [
    Title: "Build a Program Package"
    Date: 6-Jul-2001
    Version: 1.0.0
    File: %build-pack.r
    Author: "Carl Sassenrath"
    Purpose: {Creates a single compressed REBOL program from a list of file modules. Modules can include binary data files such as images.}
    Email: carl@rebol.com
    Note: "Output is text so it is compatible with all tools."
    library: [
        level: 'intermediate 
        platform: none 
        type: [Tool How-to] 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

system/options/binary-base: 64

;-- Specify a list of files that belong in the package.
;   If a file is preceded by a variable, then the file
;   is assumed to be data (such as an image) and it
;   is stored as the variable set to a binary value.
files: [
    logo: %nyc.jpg
    %show.r
]

error: func [str] [alert reform ["ERROR: " str] quit]

;-- Create a text file that contains contents of all files.
;   Load each file, then mold it back. (Removes all comments)
out: make string! 20000
variable: main: none
foreach file files [
    either any-word? :file [variable: to-word :file][
        if not exists? file [error reform ["file does not exist:" file]]
        either script? file [
            script: load/all file
            if none? main [main: script]
            append out mold/only skip script 2 ; skip REBOL header
        ][
            if variable [repend out [variable ": "]]
            append out mold read/binary file
        ]
    ]
]
if none? main [error "At least one script file is required."]
out: compress out

;-- Create a header based on the header of the first script file.
;   Add to it a decoder script and the program binary.
header: reform [
    'REBOL
    mold third make context main/2 [
        Built: now
        Length: length? out
    ]
]
repend header [
newline "code: " mold out {
if system/script/header/length <> length? code [alert "Corrupt program." quit]
do decompress code
}
]

file: request-file/only/title "Save file as:" "Save"
if file [write file header]

                                                                   