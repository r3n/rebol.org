REBOL [
    Title: "Content Management"
    Date: 14-Jun-2002/9:51:42-7:00
    Version: 1.0.0
    File: %content-management.r
    Author: "Christopher Ross-Gill"
    Rights: "Chris and ALA readers"
    Purpose: "test"
    Email: pchadwick@internews.org
    Web: http://www.alistapart.com
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'module 
        domain: [broken ldc] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

content-block: read/lines %content.txt

while [empty-string: find content-block ""][remove empty-string]

structure: copy []

foreach paragraph content-block [
    parsed?: parse paragraph [
        "Site Title:" copy para to end
        (repend structure ['site-title trim para])
        |
        "New Page:" copy para to "("
        skip copy id to ")" skip
        (repend structure ['h1 trim para id])
        |
        "===" copy para to end
        (repend structure ['h2 para])
        |
        "..." copy para to end
        (repend structure ['li para])
    ]
    if not parsed? [repend structure ['p paragraph]]
]

format-text: func [text [string!]][
    replace/all text {&} {&amp;}
    replace/all text { "} { &#8220;}
    if (first text) = #"^"" [replace text {"} {&amp;#8220;}]
    replace/all text {"} {&#8221;}
    replace/all text { '} { &#8216;}
    if (first text) = #"'" [replace text {'} {&amp;#8216;}]
    replace/all text {'} {&#8217;}
    replace/all text {--} {&#8211;}
    replace/all text { - } {&#8211;}
    replace/all text {.  } {.&#160; }

    parse/all text [
        any [
            thru {##}
            copy link to {##}
            2 skip
            copy hlink to {##}
            (
                href: {<a href="}
                nlink: link

                replace text rejoin [
                    {##} link {##} hlink {##}
                ] rejoin [
                    href lowercase copy nlink {">} hlink {</a>}
                ]
            )
        ]
        to end
    ]

    parse/all text [
        any [
            thru {**} copy emphasised to {**}
            (
                replace text rejoin [
                    {**} emphasised {**}
                ] rejoin [
                    {<em>} emphasised {</em>}
                ]
            )
        ]
        to end
    ]

    replace/all text {@} {&#064;}</pre>

    return text
]

punch-template: func [
    site-title [string!]
    page-title [string!]
    page-menu [string!]
    page-content [string!]
][
    template: read %template.html
    replace template <% page-title %> rejoin [site-title ": " page-title]
    replace template <% page-body %> rejoin [newline page-menu newline page-content newline]
    return template
]


pages: copy []
menu: copy ""

parse structure [
    (append menu <div id="menu">)
    'site-title set title string!

    some [
        'h1 set header string! set id string!
        (
            repend menu [
                newline <p> build-tag compose [
                     a href (id)
                ]
                format-text header </a> </p>
            ]
            content: copy ""
            repend content [
                newline <div id="content">
                newline <h1> format-text header </h1>
            ]
            list?: false
        )

        some [
            'h2 set para string!
            (
                if list? [append content </ul> list?: false]
                repend content [newline <h2> format-text para </h2>]
            )
            |
            'p set para string!
            (
                if list? [append content </ul> list?: false]
                repend content [newline <p> format-text para </p>]
            )
            |
            'li set para string!
            (
                if not list? [repend content [newline <ul>] list?: true]
                repend content [newline <li> format-text para </li>]
            )
        ]
        (
            if list? [append content </ul>]
            append content </div>
            repend pages [to-file id content]
        )
    ]
    (append menu </div>)
]

if not exists? %pages/ [make-dir %pages/]

foreach [file content] pages [
    write join %pages/ file punch-template title header menu content
]


                                                                                                                                                                