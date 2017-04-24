REBOL [
    Title: "navigator"
    Date: 13-Aug-2002
    Version: 1.0.0
    File: %navigator.r
    Author: "Gregory Pecheret"
    Purpose: {to navigate throw files, next versions will include web and ftp navigation}
    Email: gregory.pecheret@free.fr
    Web: http://gregory.pecheret.free.fr/index.r
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


navigator: make object! [
    url: none
    leaves: copy []
    face-for-path: none

    read-filtered: func [f] [
        ret: copy []
        if error? try [ret: read f] [
            print "problem reading directory"
        ]
                while [not tail? ret] [
                  if error? try [
                  either dir? to-file rejoin[url first ret][
                    ret: next ret
                  ][
                    remove ret
                  ]
                  ][remove ret]
                ]
                ret: head ret
        sort ret
    ]

    go-up: does [
        either "/" = to-string url [
            print "top!"
        ] [
            parsed: parse/all url "/"
            parsed: tail parsed
            parsed: back parsed
            remove parsed
            parsed: head parsed
            url: ""
            foreach p parsed [
                url: rejoin [url p "/"]
            ]
            change-to ""
        ]
    ]

    go-to: func [file] [
        url: to-file file
        change-to ""
    ]

    change-to: func [file] [
        is-dir: false
        if error? try [
            is-dir: dir? togo: to-file rejoin [url file]
        ] [
            print rejoin ["problem testing " directory scan-elt]
        ]

        if is-dir [
            url: togo
            leaves: read-filtered togo
            if face-for-path [
                face-for-path/text: togo
                show face-for-path
            ]
        ]
    ]
]



                                                                               