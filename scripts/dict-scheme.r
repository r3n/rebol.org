REBOL [
    Title: "dict protocol from dict.org"
    Date: 17-Jul-2007
    File: %dict-scheme.r
    Author: "Brian Tiffin"
    Comment: "Based on work by Jeff Kreis"
    Purpose: {Implements a dict:// protocol based on RFC2229}
    Version: 0.9.2
    Rights: "Copyright (c) 2007 Brian Tiffin"
    History: [
        0.9.0 17-Jul-2007 btiffin "First cut - mistakes non-zero probable"
        0.9.1 17-Jul-2007 btiffin "Added demo, inclusion may be overkill"
        0.9.2 18-Jul-2007 btiffin "Removed demo, now in dict-demo.r"
    ]
    Library: [
        level: 'advanced
        platform: 'all
        type: [protocol]
        domain: [text-processing scheme]
        tested-under: [
            view 1.3.2.4.2 and 2.7.5.4.2
            core 2.6.2.4.2 and 2.7.5.4.2
            Debian GNU/Linux 4.0
        ]
        support: none
        license: 'MIT
        see-also: {http://www.dict.org
                   ftp://ftp.dict.org/pub/dict/contrib/dict.rebol}
    ]
    Usage: {See http://www.rebol.org/library/scripts/dict-demo.r}
]

dict-protocol: make Root-Protocol [
    Scheme: 'dict
    Port-id: 2628
    Port-flags: system/standard/port-flags/pass-thru

    open-check: [none "220" "CLIENT REBOL" "250"]

    ;; dict servers send out CRLF (period) CRLF for each entry
    read-def: func [
        "Read a definition from the DICT server"
        port [port!]
        /local line buf
    ][
        buf: make string! 1024
        while ["." <> line: system/words/pick port 1][
            ; net-utils/confirm chews the whole line, just skip status
            line: any [find/match line "151 " line]
            foreach item (reduce [line newline]) [
                system/words/insert tail buf item
            ]
        ] buf
    ]

    query-dict: func [
        port [port!]   "The port object"
        data [block!] "A buffer"
        /local type word db strat response
        match-check define-check showdb-check
    ][
        ;; Some responses have no data, some are status
        response-msg: does [
            append data skip response 4
        ]
        no-response: does [
            append data system/words/copy ""
        ]

        define-check: [
            reform ["DEFINE" any [db "!"] word]
            ["150" "151" "250" "552"]
        ]
        match-check: [
            reform ["MATCH" any [db "!"] any [strat "."] word]
            ["152" "250" "552"]
        ]
        ;; certain status values could be confirmed, but some are errors
        showdb-check: ["SHOW DB" ["110" "554"]]
        strat-check: ["SHOW STRAT" ["111" "555"]]
        info-check: [reform ["SHOW INFO" word] "112"]
        help-check: ["HELP" ["113"]]
        server-check: ["SHOW SERVER" ["114"]]
        status-check: ["STATUS" "210"]

        ;; parse the target
        set [type word db strat] either all [port/target find port/target ":"][
            parse/all port/target ":"
        ][
            either port/target [reduce ["d" port/target]][none]
        ]

        response: net-utils/confirm port/sub-port any [
            all [type = "d" reduce define-check]
            all [type = "m" reduce match-check]
            all [type = "define" reduce define-check]
            all [type = "match" reduce match-check]
            all [type = "strat" reduce strat-check]
            all [type = "info" reduce info-check]
            all [type = "help" reduce help-check]
            all [type = "server" reduce server-check]
            all [type = "status" reduce status-check]
            showdb-check
        ]
        ;; some confirmed reponses will have no other data
        switch system/words/copy/part response 3 [
            "210" [return response-msg]
            "220" [return response-msg]
            "250" [return response-msg]
            "554" [return no-response]
            "555" [return no-response]
        ]
        ;; get a match or database list or loop over defines
        ;;   if return code isn't 150, 151 or 152 add empty
        ;; most of this code could be refactored
        any [
            all [
                any [type = "d" type = "define" type = "m" type = "match"]
                either none? find/match response "15" [
                    either any [type = "d" type = "define"] [
                        append/only data []
                    ][
                        append/only data system/words/copy ""
                    ]
                ][
                    either find/match response "150" [
                        loop to integer! second parse response none [
                            append/only data compose [(read-def port/sub-port)]
                        ]
                    ][
                        append/only data read-def port/sub-port
                    ]
                ]
            ]
            append/only data read-def port/sub-port
        ]
    ]
    ; Define the port handler version of copy...a little bit arcane
    copy: func [
        "Copy dict query into a block"
        port "The port object"
        /local msgs n
    ][
        msgs: make block! 1024
        query-dict port msgs
    ]
    ;; Install the dict port handler
    net-utils/net-install dict self 2628

    ;;
    ;; Set default dict server
    ;;
    system/schemes/dict/host: "all.dict.org"
] ;; end protocol handler
