REBOL [
    title: "Days Between"
    date: 9-feb-2009
    file: %days-between.r
    author:  Nick Antonaccio
    purpose: {
        Compute the number of days between any two dates - super simple GUI example.
        From the tutorial at http://musiclessonz.com/rebol.html
    }
]

sd: ed: now/date    
view center-face layout [
    btn "Select Start Date" [
        sd: request-date 
        sdt/text: to-string sd
        show sdt 
        db/text: to-string ((to-date edt/text) - sd)
        show db
    ]
    sdt: field to-string sd [
        either error? try [to-date sdt/text] [
            alert "Improper date format."
        ] [
            db/text: to-string ((to-date edt/text) - (to-date sdt/text))
            show db
        ]
    ]
    btn "Select End Date" [
        ed: request-date
        edt/text: to-string ed 
        show edt 
        db/text: to-string (ed - (to-date sdt/text)) 
        show db
    ]
    edt: field to-string ed [
        either error? try [to-date edt/text] [
            alert "Improper date format."
        ] [
            db/text: to-string ((to-date edt/text) - (to-date sdt/text))
            show db
        ]
    ]
    h1 "Days Between:"
    db: field "0" [
        either error? try [to-integer db/text] [
            alert "Please enter a number."
        ] [
            edt/text: to-string (
                (to-date sdt/text) + (to-integer db/text)
            )
        ]
        show edt
    ]
]