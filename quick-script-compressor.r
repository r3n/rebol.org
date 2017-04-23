REBOL [
    title: "Quick Script Compressor"
    date: 5-Jul-2011 
    file: %quick-script-compressor.r 
    author: Nick Antonaccio 
    purpose: {
        I like to distribute certain scripts in compressed format.  They're smaller
        when compressed, and the compressed syntax keeps casual peeping Toms
        from messing with the code.  Maintaining scripts with compressed code can
        be a pain, though - decompress the compressed code with REBOL, copy,
        paste and edit, then recompress, copy, paste, and save.  This little script
        makes the process of creating and editing compressed scripts simple and
        fast.
    }
]

if error? try [data: read file: request-file/only] [quit]
compressed: find data "#{"
either compressed = none [
    flag: true
    compressed: copy data
    uncompressed: copy data
] [
    flag: false
    uncompressed: decompress load compressed
]
write %uncompressed.txt uncompressed
editor %uncompressed.txt
if true <> request "Save updated file?" [
    ; alert "Changes NOT saved." 
    delete %uncompressed.txt
    quit
] 
replace data compressed (form compress read %uncompressed.txt)
if flag = true [insert head data "rebol []^/^/do decompress "]
write file data
delete %uncompressed.txt
alert "Changes saved."