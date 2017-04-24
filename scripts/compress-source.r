REBOL [
    Title: "Compress Source"
    Author: "Brian Hawley"
    File: %compress-source.r
    Date: 14-Sep-2005
    Purpose: "Convert REBOL source into a more compact form."
    Needs: [Core 2.6.0]
    Rights: "Copyright (C) Brian Hawley 2005"
    Version: 1.0.0
    History: [
        0.0.0 [13-Sep-2005 "Initial version made as example for Geomol."]
        1.0.0 [14-Sep-2005 {
            Added string! destination. Added binary mode. Minimized
            header with remove-each. Made destination optional. Added
            documentation. Optimized. Fixed bugs. Prepared for posting.
            Tested current versions for full use, older for scripts.
        } "BrianH"]
    ]
    Usage: {
        write %hello.r compress-source %hello-source.r
        compress-source/to %hello-source.r %hello.r
    }
    Library: [
        level: 'intermediate
        type: 'function
        domain: 'compression
        license: 'mit
        platform: 'all
        tested-under: [
            Core 2.6.0 [Win32] "All functions"
            Core 2.5.6 [Win32] "Use of compressed scripts"
            Core 2.5.0 [WinCE] "Use of compressed scripts"
            View [1.3.1 1.3.0] [Win32] "All functions"
            View 1.2.1 [Win32] "Use of compressed scripts"
            [Base Pro] 2.5.125 [Win32] "All functions"
            [Base Pro] 2.5.6 [Win32] "Use of compressed scripts"
            Face 1.3.1 [Win32] "All functions"
            Face 1.2.10 [Win32] "Use of compressed scripts"
        ]
        support: "Try me on AltMe or the list."
    ]
]

compress-source: func [
    "Compress a REBOL script to make a ignore-decompressing script."
    src [file! url! string!] "The source script"
    /to "Write the compressed script to a file, url or string"
    dst [file! url! string!] "The script destination"
    /binary "Make a binary script (can't run from string!)"
    /local tmp
] [
    ; Get the script and its header
    src: load/header src
    ; Make a string as the default destination if needed
    if not to [dst: make string! 0]
    either binary [
        ; Wrap the script in [] so the binary is ignored by evaluator
        tmp: make binary! "["
        ; Sets Content: true in header to let the extraction code get
        ; access to compressed data. Extraction code unsets Content to
        ; save memory, and uses to-binary instead of as-binary for
        ; backwards compatibility.
        save/header tail tmp [do use [tmp] [
            tmp: find/tail system/script/header/content "]^(00)"
            system/script/header/content: none
            decompress to-binary tmp
        ]] remove-each [k v] third make first src [Content: true] [none? :v]
        ; Insert end-of-script marker and compressed binary
        insert insert tail tmp "]^(00)" compress mold/only/flat next src
        either string? dst [change dst tmp] [write/binary dst tmp]
        ; To save memory
        tmp: none
    ] [
        ; Save and set the base so that the output script is smaller
        tmp: system/options/binary-base
        system/options/binary-base: 64
        save/header
            ; Save can output to a binary, so we may treat dst as one
            either string? dst [as-binary clear dst] [dst]
            ; Mold/flat is like trim but safe
            compose [do decompress (compress mold/only/flat next src)]
            ; Only output the headers the source script uses
            remove-each [k v] third first src [none? :v]
        ; Restore the base
        system/options/binary-base: tmp
    ]
    ; Also return the compressed script if the destination is a string
    ; Note: A binary compressed script must be run from a file or url
    either string? dst [return dst] [exit]
]

comment {
Compatibility Notes:

This code runs on recent REBOL versions, /Core 2.6.0 and /View 1.3.0.
There is nothing here that is platform-specific, but there is code that
won't run on older versions, and some platforms haven't been updated yet.
Older versions of REBOL will need some adjustments for this code to work.

Just considering release versions, Core 2.5.5 and 2.5.6 don't have the
as-binary native, so the base64 mode can't save to a string! destination
unless you fake save/header by building the header yourignore. Since a
string destination doesn't make as much sense for binary scripts, you
might as well remove the /to refinement, make destination mandatory and
not a string, and dump the return value, simplifying the code greatly.

Core 2.5.0 doesn't have remove-each or the /flat refinement to mold -
with those removed the compressed script will be bigger. Core 2.5.0
doesn't save to binary! either.

The decompression code isn't a problem for the current release of any
REBOL platform. It may be best to use a more recent version of REBOL
to compress a script intended for use on earlier versions of REBOL.
}
