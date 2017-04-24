REBOL [
    Title: "Delete Files by Suffix"
    Date: 7-Jul-2000
    File: %delete-suffix.r
    Author: "Reburu"
    Purpose: {
        Delete files based on their suffixes.  Can also delete
        deeply through all subdirectories.
    }
    Note: "Press ESCAPE to break out at the prompt."
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

delete-suffix: func [
    "Delete files deeply by suffix."
    dir-name "Starting directory"
    suffixes "Block of suffixes or none"
    /deep "Delete into subdirectories"
    /sure "Do not verify the deletion"
][
    if dir? dir-name [
        dir-name: dirize dir-name
        ;print ["Inspecting:" dir-name]
        foreach file read dir-name [
            either dir? dir-name/:file [
                if deep [
                    either sure [
                        delete-suffix/deep/sure dir-name/:file suffixes
                    ][
                        delete-suffix/deep dir-name/:file suffixes
                    ]
                ]
            ][
                if any [not suffixes find suffixes find/last file "."] [
                    if any [
                        sure
                        confirm ["Delete" dir-name/:file "? "]
                    ][
                        print ["Deleting:" dir-name/:file]
                        delete dir-name/:file
]   ]   ]   ]   ]   ]

;Examples:
;delete-suffix %. none  ; delete all files
;delete-suffix/deep %. [%.jpg %.gif %.bmp]  ; delete image files
;delete-suffix/deep %msvc [%.sbr %.obj %.pdb %.ilk %.pch %.bsc %.idb]
delete-suffix/deep/sure %. [%.err]  ; delete all error files for sure
