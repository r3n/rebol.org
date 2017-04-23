REBOL [
    Title: "Comma-Seperated-Values to REBOL converter"
    Date: 16-Jun-1999
    File: %convert-csv.r
    Author: "Bohdan Lechnowsky"
    Purpose: "^/        Convert CSV files to REBOL blocks^/    "
    Email: bo@rebol.com
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: [file-handling DB text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

csv: read/lines to-file ask "Filename to convert from CSV: "

block: make block! 100
headings: parse/all first csv ","

foreach line next csv [append block parse/all line ","]

save to-file ask "Filename to save to: " head insert/only block headings
