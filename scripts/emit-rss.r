REBOL [
    title: "Emit RSS"
    file: %emit-rss.r
    version: 1.0.0
    date: 17-Feb-2005
    author: "Christopher Ross-Gill"
    home: http://www.ross-gill.com/
    purpose: "Create an RSS Feed from a REBOL Block."
    example: {
        emit-rss [
            channel [
                title "Journal Title"
                link http://www.example.com/
                description "Describes this Journal"
                language "en-us"
                generator "REBOL Messaging Language"
            ]

            item [
                title "Journal Entry title...."
                link http://www.example.com/cgi-bin/url.r?....
                author ["You" you@example.com]
                pubdate 30-Dec-2004/12:00-9:00
                description {Journal Entry goes here...}
            ]
        ]
    }
    library: [
        level: 'intermediate
        platform: 'all
        type: [demo dialect function module tool]
        domain: [cgi dialects markup parse web xml]
        tested-under: [core 2.5.0.3.1 WinXP]
        support: none
        license: 'cc-by-sa
        see-also: none
    ]
]

languages: [ ;--- Valid RSS Languages ---
    "af" | "sq " | "eu" | "be" | "bg" | "ca" | "zh-cn" | "zh-tw" | "hr" | "cs"
    | "da" | "nl" | "nl-be" | "nl-nl" | "en" | "en-au" | "en-bz" | "en-ca" | "en-ie"
    | "en-jm" | "en-nz" | "en-ph" | "en-za" | "en-tt" | "en-gb" | "en-us" | "en-zw"
    | " et" | "fo" | "fi" | "fr" | "fr-be" | "fr-ca" | "fr-fr" | "fr-lu" | "fr-mc"
    | "fr-ch" | "gl" | "gd" | "de" | "de-at" | "de-de" | "de-li" | "de-lu" | "de-ch"
    | "el" | "haw" | "hu" | "is" | "in" | "ga" | "it" | "it-it" | "it-ch" | "ja"
    | "ko" | "mk" | "no" | "pl" | "pt" | "pt-br" | "pt-pt" | "ro" | "ro-mo"
    | "ro-ro" | "ru" | "ru-mo" | "ru-ru" | "sr" | "sk" | "sl" | "es" | "es-ar"
    | "es-bo" | "es-cl" | "es-co" | "es-cr" | "es-do" | "es-ec" | "es-sv" | "es-gt"
    | "es-hn" | "es-mx" | "es-ni" | "es-pa" | "es-py" | "es-pe" | "es-pr" | "es-es"
    | "es-uy" | "sv" | "sv-fi" | "sv-se" | "tr"
]

;--- Define Non-Ascii Chars ---
chars-xml: charset {<>&"@}
chars-ascii: charset [#"^/" #" " - #"~"]
chars-safe: exclude chars-ascii chars-xml
chars-iso: union chars-xml charset [#"^(A0)" - #"^(FF)"]
encode: func [ch [char!]][
    ch: form to-integer ch
    rejoin ["&#" head insert/dup ch "0" 3 - length? ch ";"]
]

;--- Escape Non-Ascii Chars ---
mk: ""
escape-rule: [
    mk: some chars-safe
    | #"<" (change/part mk "&lt;" 1)
    | #">" (change/part mk "&gt;" 1)
    | #"&" (change/part mk "&amp;" 1)
    | chars-iso (change/part mk encode mk/1 1)
    | skip (change mk "?")
]
escape: func [str][parse/all str: detab str [any escape-rule] str]

;--- Build RSS from REBOL Block ---
out: make string! 5000
ind: ""
emit: func [data][append out ind repend out data append out newline]
emit-tags: func ['tag txt][emit [tag: to-tag tag escape txt head insert copy tag "/"]]

txt: id: eml: none
string: [set txt string!]
author: [set txt string! set eml email!]
url: [set txt url!]

log: ""
err: func [str][log: str]

build-rss: [
    (
        clear out
        emit <?xml version="1.0"?>
        emit <rss version="2.0">
        ind: " "
    )
    'channel (emit <channel> ind: "  ")
    into [
        'title (err "No Channel Title String")
        string (emit-tags title txt)
        'link (err "No Channel Link URL")
        url (emit-tags link form txt)
        'description (err "No Channel Description String")
        string (emit-tags description txt)

        any [
            'language (err "No Channel Language Code")
            set txt languages (emit-tags language txt)
            | 'copyright (err "No Channel Copyright String")
            string (emit-tags copyright txt)
            | 'generator (err "No Channel Generator String")
            string (emit-tags generator txt)
        ]
    ]
    some [
        'item (emit <item> ind: "   ")
        into [
            'title (err "No Item Title String")
            string (emit-tags title id: txt id: mold id)
            'link (err join "No Item Link Url - " id)
            url (emit-tags link form txt)
            'author (err join "No Item Author Details - " id)
            into author (emit-tags author rejoin ["" eml " (" txt ")"])
            'pubdate (err join "No Item Date - " id)
            set txt date! (emit-tags pubDate form to-idate txt)
            'description (err join "No Item Description - " id)
            string (emit-tags description txt)
        ]
        (ind: "  " emit </item>)
    ]
    (
        ind: " " emit </channel>
        ind: "" emit </rss>
    )
]

set 'emit-rss func [channel [block!]][
    return either parse channel build-rss [out][log]
]