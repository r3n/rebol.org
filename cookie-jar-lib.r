REBOL [
    Library: [
        level: 'intermediate
        platform: 'all
        type: 'module
        domain: 'files
        tested-under: [
            [Base 2.5.6 on WinXP by Gregg]
            [Core 2.5.6 on WinXP by Gregg]
            [View [1.2.5 1.2.8 1.2.46 1.2.56] on WinXP by Gregg]
            ; uses ATTEMPT, which is not in view 1.2.1
        ]
        support: none
        license: 'MIT
        see-also: "Cookie-Jar article"
    ]

    title:   "cookie-jar reader/writer"
    file:    %cookie-jar-lib.r
    author:  "Gregg Irwin"
    email:   greggirwin@acm.org
    date:    29-Mar-2005
    version: 0.0.1
    purpose: {
        Parses cookie-jar files and returns a block of records.
        Records are blocks of either strings or name-value pairs.
        if /keep-comments is used there will be two fields for
        each record: 'content and 'comment; comment may be none.
    }
    comment: {
        * No backslash escaping in place yet
    }
]

ctx-cookie-jar: context [
    last-result: none
    data: copy []
    mode: 'no-comments
    no-comments?: does [mode = 'no-comments]
    ;-- Parse vars
    rec-content=: make string! 256
    rec-comment=: none

    emit: func [content comment] [
        if content [
            repend/only data either no-comments? [content] [[
                'content copy content 'comment attempt [copy comment]
            ]]
        ]
    ]

    ;-- parse rules
    space: charset " ^-"    ; space tab
    rec-sep: "^/%"
    record: [
        (rec-content=: rec-comment=: none)
        copy rec-content= to rec-sep thru rec-sep opt #"%"
        opt [any space copy rec-comment= to newline skip] (
            emit rec-content= rec-comment=
        )
    ]
    last-record: [
        copy rec-content= to end (emit rec-content= none)
    ]
    records: [any [record] opt last-record]


    set 'load-cookie-jar func [jar [file! string!] /keep-comments] [
        mode: either keep-comments ['keep-comments] ['no-comments]
        clear data
        last-result: parse/all either file? jar [read jar] [jar] records
        data
    ]


    set 'save-cookie-jar func [data [block!] file [file! url!] /local buffer] [
        buffer: copy ""
        foreach rec data [
            repend buffer either string? rec [
                [rec "^/%%^/"]
            ][
                [rec/content "^/%% " any [rec/comment ""] "^/"]
            ]
        ]
        write file buffer
        clear buffer
    ]

]
