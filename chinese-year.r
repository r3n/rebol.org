REBOL [
    Title: "Chinese Year"
    Version: 1.0.0
    Date: 9-Jan-2005
    File: %chinese-year.r
    Author: "Vincent Ecuyer"
    Purpose: "Chinese Year name"
    Language: 'en
    Usage: "Type in the year -> get the chinese year name"
    Comment: {
        Works under both /View and /Core,
        in english (language: 'en) and french (language: 'fr).

        Fonctionne sous /View et /Core,
        en anglais (language: 'en) et français (language: 'fr).
    }
    Library: [
        level: 'intermediate
        platform: [plugin all]
        plugin: [size: 400x100]
        type: [tool]
        domain: [math GUI]
        tested-under: [
            view 1.2.1      on [Win2K AmigaOS30]
            view 1.2.57.3.1 on [Win2K]
            core 2.5.6.3.1  on [Win2K]
            core 2.5.0.1.1  on [AmigaOS30]
        ]
        support: none
        license: 'public-domain
    ]
]

language: system/script/header/language

locale-strings: [
    year [fr "Année: " en "Year: "]
    chinese-year [fr "Année chinoise: " en "Chinese Year: "]
    animal [fr [
        "Rat" "Boeuf" "Tigre" "Lièvre" "Dragon" "Serpent"
        "Cheval" "Chèvre" "Singe" "Coq" "Chien" "Porc"
    ] en [
        "Rat" "Ox" "Tiger" "Rabbit" "Dragon" "Snake"
        "Horse" "Goat" "Monkey" "Rooster" "Dog" "Pig"
    ]]
    element [fr [
        "de Bois" "de Bois" "de Feu" "de Feu" "de Terre"
        "de Terre" "de Métal" "de Métal" "d'Eau" "d'Eau"
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
        set-text get label locale text
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
        pick locale 'animal animal
    ][
        pick locale 'element element
    ]
    add-text name-2 " "
    add-text name-2 either find [fr] language [
        pick locale 'element element
    ][
        pick locale 'animal animal
    ]
    add-text name-2 pick [" (Yang)" " (Yin)"] odd? element

    show [name-1 name-2]
]

either all [value? 'view? view? value? 'layout][
    view layout [
        size 400x100
        style mini-label label 45x15 white font [
            size: 9 colors: [255.255.255 0.0.0]
        ]
        backcolor 255.82.41
        across
        l-year: label 46x19 locale 'year year: field 70 [do-calculs]
        return
        l-chinese-year: label 97x19 locale 'chinese-year
        name-1: text "" 70  center label "/"
        name-2: text "" 150 center
        at 300x0
        mini-label "English"  [set-language 'en]
        mini-label "Français" [set-language 'fr]
        do [focus year]
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
            year/text: ask locale 'year
            if empty? year/text [quit]
            not error? try [to-integer year/text]
        ]
        do-calculs
        print rejoin [
            locale 'chinese-year
            name-1/text
            " / "
            name-2/text
        ]
    ]
]

quit