REBOL [
    Title: "Download and Extract REBOL Library"
    Date: 28-May-2001
    Version: 1.0.0
    File: %copy-lib.r
    Author: "Carl Sassenrath"
    Purpose: "Download REBOL library and extract all its files."
    Email: carl@rebol.com
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: [file-handling other-net GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

if not confirm {This script downloads a compressed archive of the
    REBOL library and extracts all files into your local script
    directory. Do you want to proceed?} [quit]

out: center-face layout [
    style tx text bold white black 200x24 middle 
    across
    vh2 "Decompressing REBOL Library"
    return
    label 60x24 right "File:"
    tf: tx
    return
    label 60x24 right "Status:"
    sf: tx "Decompressing..."
    return
    pad 68
    fc: label 92x24 "0 files"
    button "Close" [quit]
]

path: %scripts/
if not data: request-download http://www.reboltech.com/library/library.rip [
    alert "Library download failed." quit
]

if not exists? path [make-dir path]
code: context load append to-string copy/part data find data "if not exists?" "]"
archive: next find/case/tail data "!DATA:"

view/new out

if code/check <> checksum archive [sf/text: "Checksum failed."  show sf  do-events] 
n: 0
foreach [file len] code/files [
    tf/text: file  show tf
    data: decompress copy/part archive len 
    archive: skip archive len 
    write/binary path/:file data
    fc/text: reform [n: n + 1 "files"]  show fc
]

sf/text: "Decompression complete."  show sf
do-events 

