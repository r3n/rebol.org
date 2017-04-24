REBOL [
    Title: "RebProcessor"
    Date: 20-Jun-2001/15:38:23-5:00
    Version: 0.0.1
    File: %RebProcessor.r
    Author: "Seth Chromick"
    Purpose: {RebProcessor is a cross between an HTML pre-processor and a website content manager. The user creates source files (foo.src) which can contain any combination of HTML and RP commands, and the script will generate the target file (foo.html) for further use. ** EMail me for the help file, and for the example source file ** }
    Email: vache@bluejellybean.com
    library: [
        level: [intermediate advanced] 
        platform: none 
        type: none 
        domain: [file-handling markup text-processing web] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

either not system/script/args == none [
    arg: system/script/args
    arg: parse arg ""
    source-file: arg/1
    target-file: arg/2
][
    source-file: %"/c/0 Seth/RebProcessor/index.src"
    target-file: %"/c/0 Seth/RebProcessor/index.html"
]

defines: make hash! reduce [
    "_UPDATE" (join "Last updated " now)
    "_NOW"  (now)
    "_TIME" (now/time)
    "_DATE" (now/date)  ;MDY
    "_MONTH" (now/month)    ;M
    "_DAY"  (now/day)   ; D
    "_YEAR" (now/year)  ;  Y
    "_WEEKDAY" (switch now/weekday [ 
            1 ["Monday"]
            2 ["Tuesday"]
            3 ["Wednesday"]
            4 ["Thursday"]
            5 ["Friday"]
            6 ["Saturday"]
            7 ["Sunday"]
    ])
    "_FULLMONTH" (switch now/month [
            1 ["January"]
            2 ["February"]
            3 ["March"]
            4 ["April"]
            5 ["May"]
            6 ["June"]
            7 ["July"]
            8 ["August"]
            9 ["September"]
            10 ["October"]
            11 ["November"]
            12 ["December"]
    ])
]

source: make hash! read/lines source-file

forall source [
    defines: head defines
    if equal? source/1/1 #"#" [
    current-line: parse source/1 " " to-block source/1
    remove source
    switch current-line/1 [
        "#include" [
            insert read/lines to-file current-line/2
        ]
        "#define" [
            variable: current-line/2
            value:    current-line/3
            append defines current-line/2
            append defines current-line/3
        ]
        "#undefine" [
            poke defines (index: index? find defines current-line/2) ""
            poke defines (:index + 1) ""
            loop 2 [remove (find defines "")]
        ]
        "#redefine" [
            poke defines ((index? find defines current-line/2) + 1) current-line/3
        ]
        "#defdef" [
            append defines current-line/2
            a: select defines current-line/3
            b: select defines current-line/4
            append defines join a b
        ]
        "#css" [
            insert source join {<link rel="stylesheet" type="text/css" href="} [current-line/2 {">}]
        ]
        "#halt" [
            print ["#halt encountered at line " index? source "."]
            halt
        ]
        "#print" [
            print current-line/2
        ]
        "#rebol" [
            do current-line/2
        ]
    ]
    ]
    defines: head defines
    if tail? source [break]
    forskip defines 2 [
        if found? find/case source/1 defines/1 [
            replace/all source/1 defines/1 select defines defines/1
        ]
    ]
]

source: head source

foreach line source [write/append/lines target-file line]

quit