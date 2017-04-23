REBOL [
    Title:   "PDF label maker"
    Purpose: "Create labels with PDF-Maker"
    Author:  "Gregg Irwin"
    File:    %pdf-labels.r
    Date:    17-Mar-2004
    Version: 0.0.2
    Library: [
        level: 'advanced
        platform: 'all
        type: [demo how-to]
        domain: [graphics printing text]
        tested-under: [view 1.2.8]
        support: none
        license: 'public-domain
        see-also: %pdf-maker.r
    ]
    History: [
        04-Nov-2003 0.0.1 "Initial Release"
        17-Mar-2004 0.0.2 "Made things a little more reusable"
    ]
    Comment: {
        Layout is fixed for 3x10 labels on 8.5x11 paper. If someone
        wants to make it more flexible, that would be great.
        More flexible data support would be terrific as well.
    }
]

pdf-labels: context [
    if not value? 'layout-pdf [do %pdf-maker.r]

    rows-per-page: 10
    cols-per-page: 3
    labels-per-page: 30

    x-coordinate: [6.223 76.073 145.923]
    y-coordinate: [241.3 215.9 190.5 165.1 139.7 114.3 88.9 63.5 38.1 12.7]


    ; Assuming a block containing these fields:
    ;   first last street city state zip
    ; form it into a string, with newlines after the name and street address
    format-label-text: func [
        data "A block containing a single record"
        /local result
    ][
        form head insert next insert at copy data 3 newline newline
    ]

    make-page: func [
        "Make one page of labels"
        data "One page worth of data (max)"
        /local result cell
    ][
        result: copy [page size 215.9  279.4]
        repeat row rows-per-page [
            repeat col cols-per-page [
                either (cell: row - 1 * cols-per-page + col) <= length? data [
                    append result dbg: compose/deep [
                        ;textbox x y w h text
                        textbox
                            (x-coordinate/:col) (y-coordinate/:row)
                            63.246 21.4 [
                            as-is font Times-Roman 3.53
                            (format-label-text pick data cell)
                        ]
                    ]
                ][
                    return result
                ]
            ]
        ]
        result
    ]

    make-pages: func [
        "Make pages of labels for all data"
        data    "All data"
        /local page-count result
    ][
        result: copy []
        page-count: to integer! divide length? data labels-per-page
        if 0 <> remainder length? data labels-per-page [
            page-count: page-count + 1
        ]
        repeat page page-count [
            append/only result make-page copy/part
                at data 1 + (page - 1 * labels-per-page)
                labels-per-page
        ]
        result
    ]

    set 'make-pdf-labels func [data /write-to file /local pdf dbg-lay] [
        pdf: layout-pdf lay: make-pages data
        if file [write/binary file pdf]
        ; for testing
        ;save %labels.lay dbg-lay
        pdf
    ]
]


;-- Test Code

test: on

if test [
    ; The address data is in the following format - typically the block will
    ; contain a couple of hundred addresses:
    addresses: copy []
    repeat i 60 [
        append addresses compose/deep [
            [(join "JOE-" i) "BLOW" "1234 MELISSA DRIVE" "BURLINGTON" "VT" "00822-2957"]
            [(join "JILL-" i) "BLOW" "5678 CAMAY CIRCLE" "PUTNAM" "MA" "00123-5678"]
        ]
    ]

    write/binary %labels.pdf make-pdf-labels addresses

    browse %labels.pdf
]
