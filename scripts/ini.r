REBOL [
    Title: "Load-ini"
    Date: 9-Apr-2002
    Version: 0.0.3
    File: %ini.r
    Author: "oldes"
    Purpose: "Tries to load ini-structured file to Rebol"
    Email: oliva.david@seznam.cz
    note: {This is just simple version that doesn't work with more complex files containing multiline strings or arrays!}
    library: [
        level: none 
        platform: none 
        type: 'tool 
        domain: 'DB 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

load-ini: func[
    "Tries to load ini-structured file to Rebol"
    ini-file [file! string! url!]   "File to parse"
    /local _sp _allchars _space _comm _section _property
    data tmp section property value new-sect
][
    _sp: charset [#" " #"^-"]
    _allchars: complement charset [#"^/" #"="]
    _space: [some _sp]

    _comm: [
        opt _space [#"#" | #";"] copy comm [to newline | to end] (if none? comm [comm: ""])
    ]
    _blankline: [ opt _space opt _comm newline]
    _section: [opt newline opt _space #"[" copy newsection to #"]" skip opt _space]
    _property: [opt newline opt _space
        copy property to #"=" skip
        copy value [to newline | end]
    ]

    data: make block! []
    tmp: make block! []
    section: value: none
    if not string? ini-file [ini-file: read ini-file]
    new-sect: func[][
        if section <> none [
            repend data [section copy tmp]
        ]
        clear tmp
    ]
    parse ini-file [
        some [
              _comm ;(print ["comm:" comm])
            | _blankline
            | _section  (
                new-sect
                section: copy newsection
                error? try [section: to-word section]
                ;probe section
            )
            | _property (
                value: either none? value [none][
                    value: trim value
                    error? try [if not empty? value [value: load value]]
                    value
                ]
                property: trim/tail property
                error? try [property: to-word property]
                ;print ["pr:" tab property "=" value]
                repend tmp [property value]
                value: none
            )
        ]
        (new-sect)
    ]
    data
]                                                                    