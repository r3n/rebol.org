REBOL [
    Title: "Chinese Year"
    Version: 1.1.0
    Date: 28-Jan-2013
    File: %chinese-year.r
    Author: "Vincent Ecuyer"
    Purpose: "Chinese Year name"
    Language: 'en
    Usage: "Type in the year -> get the chinese year name"
    Comment: {
        Works under both /View and /Core,
        in english (language: 'en) and french (language: 'fr).

        Fonctionne sous /View et /Core,
        en anglais (language: 'en) et francais (language: 'fr).
    }
    Library: [
        level: 'intermediate
        platform: [plugin all]
        plugin: [size: 420x100]
        type: [tool]
        domain: [math GUI]
        tested-under: [
            core 2.7.8.2.4 on [Macintosh osx-x86]
            core 2.7.8.2.5 on [Macintosh osx-x86]
            view 2.7.8.2.5 on [Macintosh osx-x86]
            view 2.7.8.3.1 on [WinXP]
            core 2.101.0.2.5 on [Macintosh osx-x86]
        ]
        support: none
        license: 'public-domain
    ]
    History: [
        1.1.0 28-Jan-2013 "Fixed MacOs text encoding and checked r3 compatibility"
        1.0.0  9-Jan-2005 "First published version"
    ]
]

language: system/script/header/language
encoding: either all [
    system/version > 2.100.0
]['utf8][                                            ; REBOL 3 uses unicode
    either system/version/4 = 2 ['MacRoman]['Latin1] ; MacOs / Others
]

locale-strings: [
    year [
        fr [#{416E6EE9653A20} #{416E6E8E653A20} #{416E6EC3A9653A20}]
        en "Year: "
    ]
    chinese-year [
        fr [#{416E6EE965206368696E6F6973653A20}
            #{416E6E8E65206368696E6F6973653A20}
            #{416E6EC3A965206368696E6F6973653A20}]
        en "Chinese Year: "
    ]
    animal [fr [
        "Rat" "Boeuf" "Tigre" 
        [#{4C69E8767265} #{4C698F767265} #{4C69C3A8767265}] 
        "Dragon" "Serpent" "Cheval" 
        [#{4368E8767265} #{43688F767265} #{4368C3A8767265}] 
        "Singe" "Coq" "Chien" "Porc"
    ] en [
        "Rat" "Ox" "Tiger" "Rabbit" "Dragon" "Snake"
        "Horse" "Goat" "Monkey" "Rooster" "Dog" "Pig"
    ]]
    element [fr [
        "de Bois" "de Bois" 
        "de Feu" "de Feu" 
        "de Terre" "de Terre" 
        [#{6465204DE974616C} #{6465204D8E74616C} #{6465204DC3A974616C}] 
        [#{6465204DE974616C} #{6465204D8E74616C} #{6465204DC3A974616C}] 
        "d'Eau" "d'Eau"
    ] en [
        "Wood" "Wood" "Fire" "Fire" "Earth"
        "Earth" "Metal" "Metal" "Water" "Water"
    ]]
]
gui-strings: [
    l-year year 
    l-chinese-year chinese-year
]

locale: func [value][
    copy select select locale-strings value language
]
encoded: func [value][
    either block? value [to-string pick value index? find [
        Latin1 MacRoman utf8
    ] encoding][value] 
]

set-text: func [face value][
    either face/text [append clear face/text value][face/text: copy value]
]
add-text: func [face value][
    either face/text [append face/text value][face/text: copy value]
]

mod-3: func [face value][
    if error? try [face: do trim face/text][face: 0]
    face: face - 3 // value
    either positive? face [face][face + value]
]

set-language: func [value][
    language: value
    foreach [label text] gui-strings [
        set-text get label encoded locale text
        show get label
    ]
    if all [year/data not empty? year/data][do-calculs]
]

do-calculs: does [
    animal: mod-3 year 12
    element: mod-3 year 10

    set-text name-1 pick [
        "Jia" "Yi" "Bing" "Ding" "Wu"
        "Ji" "Geng" "Xin" "Ren" "Gui"
    ] element
    add-text name-1 "-"
    add-text name-1 pick [
        "Zi" "Chou" "Yin" "Mao" "Chen" "Si"
        "Wu" "Wei" "Shen" "Yu" "Xu" "Hai"
    ] animal

    set-text name-2 either find [fr] language [
        encoded pick locale 'animal animal
    ][
        encoded pick locale 'element element
    ]
    add-text name-2 " "
    add-text name-2 either find [fr] language [
        encoded pick locale 'element element
    ][
        encoded pick locale 'animal animal
    ]
    add-text name-2 pick [" (Yang)" " (Yin)"] odd? element

    show [name-1 name-2]
]

either all [value? 'view? view? value? 'layout][
    view layout [
        size 420x100
        style mini-label label 60x15 white font [
            size: 9 colors: [255.255.255 0.0.0]
        ]
        backcolor 255.82.41
        across
        l-year: label 49x19 encoded locale 'year year: field 70 [do-calculs]
        return
        l-chinese-year: label 100x19 encoded locale 'chinese-year
        name-1: text "" 70  center label "/"
        name-2: text "" 150 center
        at 280x0
        mini-label "English"  [set-language 'en]
        mini-label encoded [
            #{4672616EE7616973} 
            #{4672616E8D616973} 
            #{4672616EC3A7616973}
        ] [set-language 'fr]
        do [
            set-language language
            focus year
        ]
    ]
][
    name-1: make object! [text: none]
    name-2: make object! [text: none]
    year: make object! [text: none]
    show: func [value][
        value: append copy [] value
        foreach item value [
            item: get item
            if none? item/text [item/text: copy ""]
        ]
    ]

    forever [
        until [
            year/text: ask encoded locale 'year
            if empty? year/text [quit]
            not error? try [to-integer year/text]
        ]
        do-calculs
        print rejoin [
            encoded locale 'chinese-year
            name-1/text
            " / "
            name-2/text
        ]
    ]
]

quit