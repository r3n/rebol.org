REBOL [
    Title: "Tar"
    Date: 11-Jan-2013
    Version: 1.1.0
    File: %tar.r
    Author: "Vincent Ecuyer"
    Purpose: {Creates tar archives.}
    Usage: {
        With one file:
            write/binary %test.tar tar %my-file.txt

        With a block of files:
            write/binary %test.tar tar [%my-file.txt %my-dir/my-file.bmp %just-a-dir/]

        You can of course gzip the tar (with %gzip.r):
        
            do %tar.r
            do %gzip.r

            write/binary %test.tgz gzip tar [%some-files ...]

            Resulting archive is usually smaller than a *.zip of the same files
			
        Compatibility tested with 7-Zip 9.20 on WindowsXP SP3 and bsdtar 2.6.2 on MacOSX 10.6.8.
    }
    History: [
        1.0.0 [2-Jan-2004 "First release"]
        1.1.0 [11-Jan-2013 "Fixed end-of-file padding and added r3 comptability"]
    ]
    Library: [
        level: 'advanced
        platform: 'all
        type: [module tool]
        domain: [file-handling files compression]
        tested-under: [
        	view 2.7.8.3.1 on [WinXP]
        	view 2.7.8.2.5 on [Macintosh osx-x86]
        	core 2.101.0.2.5 on [Macintosh osx-x86]
        ]
        support: none
        license: 'public-domain
        see-also: %gzip.r
    ]
]

ctx-tar: context [
    get-modes: either (system/version/2 < 100) [
        get in system/words 'get-modes
    ][
        func [target mode][query/mode target mode]
    ]

    to-octal: func [
        "Converts an integer to an octal issue!."
        value [integer!] "Value to be converted"
        /local t
    ][
        value: join "0" enbase/base at tail do rejoin ["16#{" next mold to-hex value "}"] -4 2
        t: copy {}
        forskip value 3 [
            copy/part value 3
            append t next
            enbase/base do rejoin ["2#{00000" copy/part value 3 "}"] 16
        ]
        t
    ]

    octal-time: func [
        "Returns the octal timestamp."
        value [date!] "Date to encode"
    ][
        to-octal (value - 01/01/1970) * 86400
        + to-integer value/time - value/zone
    ]

    char: func [
        "Encodes the value into a null terminated fixed length string."
        value [any-string! binary!] "String to encode"
        len [integer!] "Required length"
    ][
        copy/part head insert/dup tail to-binary value #{00} len len
    ]

    num: func [
        "Encodes the value into a fixed length octal string."
        value [integer!] "Number to encode"
        len [integer!] "Required length"
    ][
        value: head insert/dup form to-octal value "0" len
        copy skip tail value (0 - len)
    ]

    ;number terminator
    stop: " ^@"

    ;string terminator
    null: "^@"

    ;file access rights
    tar-modes: [
        owner-read   00400  owner-write  00200  owner-exec   00100
        group-read   00040  group-write  00020  group-exec   00010
        world-read   00004  world-write  00002  world-exec   00001
    ]

    set-name: func [
        "Returns the formatted filename."
        value [file!] "File name to format"
    ][char join value null 100]

    set-mode: func [
        "Returns the octal encoded file access mode."
        value [file!] "File to examine"
        /local mode modes
    ][
        modes: get-modes value 'file-modes
        mode: 0
        foreach m [owner-read owner-write owner-exec][
            either find modes m
                [if get-modes value m [mode: mode + tar-modes/:m]]
                [mode: mode + tar-modes/:m]
        ]
        foreach m [
            group-read group-write group-exec
            world-read world-write world-exec
        ][if all [find modes m get-modes value m][mode: mode + tar-modes/:m]]
        mode: form mode
        append mode stop
        insert mode "0000000"
        copy skip tail mode -8
    ]

    set-typeflag: func [
        "Returns the type code for file / directory."
        value [file!] "File name to examine"
    ][either #"/" = last value ["5"]["0"]]

    tar-checksum: func [
        "Returns an octal string with the sum of bytes."
        data [any-string! binary!] "Data to checksum"
        /local r
    ][
        r: 0
        foreach c data [r: r + c]
        join num r 6 stop
    ]

    add-file: func [value [file!] /local r][
        r: to-binary rejoin [
            set-name value
            set-mode value
            "000000" stop
            "000000" stop
            num size? value 11 " "
            octal-time modified? value " "
            "        "          ;  char chksum 8
            set-typeflag value
            char null 100       ;  char linkname 100
            char null 6         ;  char magic 6
            "00"                ;  char version 2
            char null 32        ;  char uname 32
            char null 32        ;  char gname 32
            num 0 6 stop        ;  char devmajor 8
            num 0 6 stop        ;  char devminor 8
            char null 155       ;  char prefix 155
        ]
        change skip r 148 tar-checksum r
        r: head insert/dup tail r #{00} 512 - length? r
        if #"/" <> last value [
            append r either system/version/2 < 100 [read/binary value][read value]
            if 0 <> ((length? r) // 512) [
                r: head insert/dup tail r #{00} 512 - ((length? r) // 512)
            ]
        ]
        r
    ]

    set 'tar func [
        "Builds a tar archive binary from a file or a block of files."
        value [file! block!] "Files to include in archive"
        /local r
    ][
        if file? value [value: reduce [value]]
        r: copy #{}
        foreach file value [append r add-file file]
        head insert/dup tail r #{00} 1024
    ]
]
